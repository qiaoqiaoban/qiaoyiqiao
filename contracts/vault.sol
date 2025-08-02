// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;
import "./lp.sol";
// Simplified ERC20 interface (only includes functions used)

contract Vault {
    // USDT and USDC token addresses
    address public usdt;
    address public usdc;
    lps public lpusdt;
    lps public lpusdc;
    lps public lpeth;
    address public owner;

    mapping(address => bool) public whiteList;
    // Enum to differentiate asset types
    enum TokenType { ETH, USDT, USDC }
    // Mapping to record user's outstanding borrow amounts
    mapping(address => mapping(TokenType => uint256)) public borrowed;
    mapping(TokenType => uint256) public borrowedOut;
    mapping(TokenType => uint256) public repayOut;
    
    // Events for logging actions
    event Deposit(address indexed user, TokenType tokenType, uint256 amount,uint256 lp);
    event Withdraw(address indexed user, TokenType tokenType, uint256 amount,uint256 lp);
    event Borrow(address indexed user, TokenType tokenType, uint256 amount);
    event Repay(address indexed user, TokenType tokenType, uint256 repaidAmount);
    
    constructor(address _usdt, address _usdc) {
        usdt = _usdt;
        usdc = _usdc;
        owner = msg.sender;
        lpusdt = new lps("LPUSDT","lpusdt");
        lpusdc = new lps("LPUSDC","lpusdc");
        lpeth = new lps("LPETH","lpeth");
    }
    function updateWhiteList(address who , bool statu) external {
        whiteList[who]=statu;
    }
    /// @notice Deposit ETH and receive corresponding LP tokens
    function depositETH() external payable {
        require(msg.value > 0, "Must deposit some ETH");
        uint256 lpAmount;
        if(lpeth.totalSupply()>0)
        {
            lpAmount = (msg.value*(address(this).balance - msg.value))/lpeth.totalSupply();
        }else{
            lpAmount = msg.value;
        }
        lpeth.mint(lpAmount,msg.sender);
        emit Deposit(msg.sender, TokenType.ETH, msg.value,lpAmount);
    }
    
    /// @notice Deposit USDT or USDC and receive corresponding LP tokens
    /// @param token The token address (only USDT or USDC are supported)
    /// @param amount The deposit amount
    function deposit(address token, uint256 amount) external {
        require(amount > 0, "Deposit amount must be greater than zero");
        TokenType tokenType;
        uint256 lpAmount;
        if(token == usdt) {
            tokenType = TokenType.USDT;
            if(lpusdt.totalSupply()>0)
            {
                lpAmount = (amount*(IERC20(usdt).balanceOf(address(this))- amount))/lpusdt.totalSupply();
            }else{
                lpAmount = amount;
            }
            lpusdt.mint(lpAmount,msg.sender);
        } else if(token == usdc) {
            tokenType = TokenType.USDC;
            if(lpusdc.totalSupply()>0)
            {
                lpAmount = (amount*(IERC20(usdc).balanceOf(address(this))- amount))/lpusdc.totalSupply();
            }else{
                lpAmount = amount;
            }
            lpusdc.mint(lpAmount,msg.sender);
        } else {
            revert("Unsupported token");
        }
        emit Deposit(msg.sender, tokenType, amount,lpAmount);
    }
    
    /// @notice Burn LP tokens to withdraw the corresponding asset
    /// @param tokenType The type of asset to withdraw
    /// @param amount The amount to withdraw
    function redeem(TokenType tokenType, uint256 amount) external {
        uint256 reciveAmount;
        if(tokenType == TokenType.ETH) {
            lpeth.burnFrom(amount,msg.sender);
            reciveAmount = (address(this).balance * amount) / (lpeth.totalSupply()+amount+borrowedOut[tokenType]);
            payable(msg.sender).transfer(
               reciveAmount
            );
        } else if(tokenType == TokenType.USDT) {
             lpusdt.burnFrom(amount,msg.sender);
             reciveAmount =(IERC20(usdt).balanceOf(address(this)) * amount) / (lpusdt.totalSupply()+amount+borrowedOut[tokenType]);
            require(IERC20(usdt).transfer(msg.sender, reciveAmount), "USDT transfer failed");
        } else if(tokenType == TokenType.USDC) {
            lpusdc.burnFrom(amount,msg.sender);
            reciveAmount =(IERC20(usdc).balanceOf(address(this)) * amount) / (lpusdc.totalSupply()+amount+borrowedOut[tokenType]);
            require(IERC20(usdc).transfer(msg.sender, amount), "USDC transfer failed");
        }
        emit Withdraw(msg.sender, tokenType,reciveAmount, amount);
    }
    
    /// @notice Borrow tokens from the contract (no collateral required, for demonstration only)
    /// @param tokenType The type of asset to borrow
    /// @param amount The amount to borrow
    function borrow(TokenType tokenType, uint256 amount) external {
        require(amount > 0, "Borrow amount must be greater than zero");
        require(whiteList[msg.sender],"Not allows");
        if(tokenType == TokenType.ETH) {
            require(address(this).balance >= amount, "Not enough ETH in contract");
            payable(msg.sender).transfer(amount);
        } else if(tokenType == TokenType.USDT) {
            require(IERC20(usdt).balanceOf(address(this)) >= amount, "Not enough USDT in contract");
            require(IERC20(usdt).transfer(msg.sender, amount), "USDT transfer failed");
        } else if(tokenType == TokenType.USDC) {
            require(IERC20(usdc).balanceOf(address(this)) >= amount, "Not enough USDC in contract");
            require(IERC20(usdc).transfer(msg.sender, amount), "USDC transfer failed");
        }
        borrowed[msg.sender][tokenType] += amount;
        borrowedOut[tokenType]+=amount;
        emit Borrow(msg.sender, tokenType, amount);
    }
    
    /// @notice Repay borrowed tokens (each repayment incurs a 1% fee; partial repayments allowed)
    /// @param tokenType The type of asset being repaid
    /// @param amount The principal amount to repay (excluding fee)
    /// @dev For ETH repayments, the user must send amount+fee ETH; for tokens, the user must approve the contract beforehand.
    function repay(TokenType tokenType, uint256 amount,uint256 debt) external payable {
        require(amount > debt, "Repay amount must be greater than debt");
        require(whiteList[msg.sender],"Not allows");
        
        // Calculate a 1% fee on the repayment amount
        uint256 totalRepay = amount ;
        
        if(tokenType == TokenType.ETH) {
            require(msg.value == totalRepay, "Incorrect ETH amount sent");
            // The received ETH (including fee) is kept in the contract; fee remains in the contract
        } else if(tokenType == TokenType.USDT) {
            require(IERC20(usdt).transferFrom(msg.sender, address(this), totalRepay), "USDT transfer failed");
        } else if(tokenType == TokenType.USDC) {
            require(IERC20(usdc).transferFrom(msg.sender, address(this), totalRepay), "USDC transfer failed");
        }
        borrowed[msg.sender][tokenType] -= debt;
        borrowedOut[tokenType]-=debt;
        repayOut[tokenType]+=amount-debt;
        emit Repay(msg.sender, tokenType, amount);
    }
    
    // Fallback function to receive ETH deposits
    receive() external payable {}
}
