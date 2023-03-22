// SPDX-License-Identifier: GPL-3.0 
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./IERC20.sol";

contract MonkeyGame is ReentrancyGuard, Ownable {
    IERC20 public token;

    struct LevelReward{
        uint256 level;
        uint256 reward;
    }

    address public devWallet;
    uint256 public entryFee = 25 * 10000;
    uint256 public tryResetTime = 1 days;
    uint256 public lastTryReset;
    LevelReward[] public levelReward;

    mapping( address => uint256 ) public tokensEarned;
    mapping( address => uint256 ) public tokensBurned;
    mapping( address => uint256 ) public triesRemaining;
    mapping( address => bool ) public alreadyPlayedToday;
    mapping ( address => uint256 ) public playerLevel;

    event EntryFeePaid( address indexed player, uint256 feeAmount );
    event TokensEarned( address indexed player, uint256 tokenAmount );
    event TokensBurned( address indexed player, uint256 tokenAmount );
    event LevelUp( address indexed player, uint256 levelQuantity );
    
    constructor( address tokenAddress, address devWallet_ ) {
        token = IERC20( tokenAddress );
        devWallet = devWallet_;
        lastTryReset = block.timestamp;
        triesRemaining[ msg.sender ] = 10;
    }

    function startGame() public {
        require( !alreadyPlayedToday[ msg.sender ], "You have already played today" );
        require( _chkTriesRemaining( msg.sender ) == true, "You can not play Game");
        require( token.balanceOf( msg.sender ) >= entryFee, "Not enough tokens to play" );
        require( _initGame(), "Game could not init." );
        
        bool flgToContract = token.transferFrom( msg.sender, address( this ), entryFee );
        require( flgToContract == true, "Tokens Transaction have to transfer into game is failed!" );
        emit EntryFeePaid( msg.sender, entryFee );
        
        uint256 devFee = entryFee / 10;
        bool flgToDev = token.transferFrom( address( this ), devWallet, devFee );
        require( flgToDev == true, "Tokens Transaction have to transfer to dev is failed!" );

        uint256 burnAmount = entryFee - devFee;
        tokensBurned[ msg.sender ] += burnAmount;
        bool flgBurn = token.burn( burnAmount );
        require( flgBurn == true, "Tokens doesn't burn" );
        emit TokensBurned( msg.sender, burnAmount );
    }

    function restartLevel() public {
        require( alreadyPlayedToday[ msg.sender ], "You haven't started game." );
        uint256 potentialReward = levelReward[ playerLevel[ msg.sender ] ].reward;
        require( _chkTriesRemaining( msg.sender ) == true, "You can not play Game");
        require( tokensEarned[ msg.sender] >= potentialReward, "Not enough tokens earned for restart" );
        
        uint256 restartFee = potentialReward * 40 / 100;
        require( token.balanceOf( msg.sender ) >= restartFee, "Not enough tokens to restart" );
        tokensEarned[ msg.sender ] -= restartFee;
        tokensBurned[ msg.sender ] += restartFee;
        
        bool flgToContract = token.transferFrom( msg.sender, address( this ), restartFee );
        require( flgToContract == true, "Tokens Transaction have to transfer into game is failed!" );
        
        uint256 devFee = restartFee / 10;
        bool flgToDev = token.transferFrom( address( this ), devWallet, devFee );
        require( flgToDev == true, "Tokens Transaction have to transfer to dev is failed!" );
        
        uint256 burnAmount = restartFee - devFee;
        tokensBurned[ msg.sender ] += burnAmount;
        bool flgBurn = token.burn( burnAmount );
        require( flgBurn == true, "Tokens doesn't burn" );
        emit TokensBurned( msg.sender, burnAmount );
    }

    function levelUp( address player_ ) public{
        require( alreadyPlayedToday[ msg.sender ], "You haven't started game." );

        playerLevel[ player_ ] ++;

        uint256 upReward = levelReward[ playerLevel[ player_ ] ].reward;
        tokensEarned[ player_ ] += upReward;
        token.transferFrom( address( this ), msg.sender, upReward );
        
        emit TokensEarned( player_, upReward );
        emit LevelUp( player_, playerLevel[ player_ ] );
    }

    function gameOver() public{
        require( alreadyPlayedToday[ msg.sender ], "Game didn't started" );
        require( _initGame(), "Game can't over.");
        playerLevel[ msg.sender ] = 0;
        alreadyPlayedToday[ msg.sender ] = false;
    }
    
    function setLevelReward( LevelReward[] memory levelList ) public onlyOwner{
        uint256 levelSize = levelList.length;
        uint256 lvlRwdSize = levelReward.length;
        
        for( uint256 i=0; i < lvlRwdSize; i++ ){
            levelReward.pop();
        }

        for( uint256 i = 0; i < levelSize; i++ ){
            LevelReward memory lvlRwd = levelList[ levelSize ];
            levelReward.push( lvlRwd );
        }
    }

    function setLvlRwdAuto( uint256 initAmount_, uint256 rate_, uint256 lastLevel ) public onlyOwner{
        uint256 lvlRwdSize = levelReward.length;        
        for( uint256 i=0; i < lvlRwdSize; i++ ){
            levelReward.pop();
        }
        
        uint256 curAmount = initAmount_;
        for( uint256 i = 0; i < lastLevel; i++ ){
            curAmount += curAmount * rate_ / 100;
            
            LevelReward memory lvlRwd;
            lvlRwd.level = i;
            lvlRwd.reward = ( curAmount - initAmount_ );

            levelReward.push( lvlRwd );
        }
    }

    function setEntryFee( uint256 entryFee_ ) external{
        entryFee = entryFee_;
    }

    function getEntryFee( ) external view returns( uint256 ){
        return entryFee;
    }

    function _seedLvlReward() private {             // for Test
        setLvlRwdAuto( entryFee / 10, 30, 12 );
    }

    function _initGame() private returns( bool ){
        playerLevel[ msg.sender ] = 1;
        tokensEarned[ msg.sender ] = 0;
        tokensBurned[ msg.sender ] = 0;
        alreadyPlayedToday[ msg.sender ] = true;
        _seedLvlReward();

        bool flgLvl = playerLevel[ msg.sender] == 1;
        bool flgEarned = tokensEarned[ msg.sender ] == 0;

        return flgLvl && flgEarned;
    }

    function _chkTriesRemaining( address player_  ) private returns( bool ) {
        uint256 currentTime = block.timestamp;
        uint256 duePlayingTime = currentTime - lastTryReset;

        if( duePlayingTime >= tryResetTime ){
            triesRemaining[ player_ ] = 10;
            lastTryReset = currentTime;
        }

        require( triesRemaining[ player_ ] > 0, "You have no tries remaining for today" );        
        triesRemaining[ player_ ]--;

        return true;
    }
}