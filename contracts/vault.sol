// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import '@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol';
import '@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router01.sol';

// interface IUniswapV2Router01 {
//         function addLiquidity(
//         address tokenA,
//         address tokenB,
//         uint amountADesired,
//         uint amountBDesired,
//         uint amountAMin,
//         uint amountBMin,
//         address to,
//         uint deadline
//     ) external returns (uint amountA, uint amountB, uint liquidity);
//     }


contract Vault {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct Items {
        IERC20 token1;
        IERC20 token2;
        address withdrawer;
        uint256 amount1;
        uint256 amount2;
    }

    uint256 public depositsCount;
    mapping (uint256 => Items) public lockedToken;
    

    // on polygon
    address constant factory = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    address constant token1 = 0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619; //WETH
    address constant token2 = 0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174; //USDC
    // address constant pair_address = address(uint(keccak256(abi.encodePacked(
    //     hex'ff',
    //     factory,
    //     keccak256(abi.encodePacked(token1, token2)),
    //     hex'96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f'
    // ))));

    
    function approve(IERC20 _token1, IERC20 _token2, address spender, uint256 _amount1, uint256 _amount2) external returns (bool) {
        _token1.safeApprove(spender,_amount1);
        _token2.safeApprove(spender,_amount2);
    }

    function lockTokens(IERC20 _token1, IERC20 _token2, address _withdrawer, uint256 _amount1, uint256 _amount2) external returns (uint256 _id) {
        require(_token1.allowance(msg.sender, address(this)) >= _amount1, 'Approve tokens first!');
        require(_token2.allowance(msg.sender, address(this)) >= _amount2, 'Approve tokens first!');
        _token1.safeTransferFrom(msg.sender, address(this), _amount1);
        _token2.safeTransferFrom(msg.sender, address(this), _amount2);

        _id = ++depositsCount;
        lockedToken[_id].token1 = _token1;
        lockedToken[_id].token2 = _token2;
        lockedToken[_id].withdrawer = _withdrawer;
        lockedToken[_id].amount1 = _amount1;
        lockedToken[_id].amount2 = _amount2;
        
    }


    // function addLiquidity(
    //     address tokenA,     
    //     address tokenB,
    //     uint amountADesired,
    //     uint amountBDesired,
    //     uint amountAMin,
    //     uint amountBMin,
    //     address to,
    //     uint deadline
    // ) external returns (uint amountA, uint amountB, uint liquidity);

    
    function allocateToPool(uint256 _id) external returns (bool) {
        addLiquidity(
            lockedToken[_id].token1,
            lockedToken[_id].token2,
            lockedToken[_id].amount1, 
            lockedToken[_id].amount2,
            0,0,
            msg.sender,
            0            
        );
    }



    




    
}
