// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

enum TokenType { ETH, USDT, USDC }

interface IUniswapV2Router02 {
    function swapExactETHForTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);

    function swapExactTokensForETH(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function getAmountsOut(uint amountIn, address[] memory path) external view returns (uint[] memory amounts);
    function WETH() external pure returns (address);
}

interface IVault {
    function borrow(TokenType tokenType, uint256 amount) external;
    function repay(TokenType tokenType, uint256 amount ,uint256 debt) payable external;
}

contract qqb_protocol is Ownable(msg.sender) {
    address public usdt;
    address public usdc;
    IVault public vault;
    address public uniswapRouter;
    address public tokenAddress;

    uint256 public constant FEE_PERCENTAGE = 100;
    uint256 public totalFees;

    struct Position {
        TokenType types;
        address owner;
        uint256 mortgageAmount;
        uint256 investAmount;
        uint256 tokenAmount;
        bool isOpen;
        uint256 openTime;
    }

    mapping(uint256 => Position) public positions;
    mapping(address => uint256[]) public userPositions;
    uint256 private positionIdCounter;

    event PositionOpened(uint256 indexed positionId, address indexed owner, uint256 mortgageAmount, uint256 investAmount, uint256 tokenAmount);
    event PositionClosed(uint256 indexed positionId, address indexed owner, uint256 returnedETH, uint256 fee);

    constructor(address _uniswapRouter, address _tokenAddress, address _usdt, address _usdc, address _vault) {
        uniswapRouter = _uniswapRouter;
        tokenAddress = _tokenAddress;
        positionIdCounter = 1;
        usdt = _usdt;
        usdc = _usdc;
        vault = IVault(_vault);

        IERC20(_tokenAddress).approve(_uniswapRouter, type(uint256).max);
        IERC20(_usdt).approve(_uniswapRouter, type(uint256).max);
        IERC20(_usdc).approve(_uniswapRouter, type(uint256).max);
    }

    function buy(TokenType types, uint256 mortgage, uint256 amount) external payable {
        uint[] memory amounts;
        require(mortgage * 10 >= amount, "Reach max leverage");
        vault.borrow(types, amount - mortgage);

        if (types == TokenType.ETH) {
            require(msg.value == mortgage, "Insufficient ETH sent for mortgage");
            address[] memory path = new address[](2);
            path[0] = IUniswapV2Router02(uniswapRouter).WETH();
            path[1] = tokenAddress;
            amounts = IUniswapV2Router02(uniswapRouter).swapExactETHForTokens{value: amount}(0, path, address(this), block.timestamp + 15 minutes);

        } else if (types == TokenType.USDT) {
            IERC20(usdt).transferFrom(msg.sender, address(this), mortgage);
            address[] memory path = new address[](2);
            path[0] = usdt;
            path[1] = tokenAddress;
            amounts = IUniswapV2Router02(uniswapRouter).swapExactTokensForTokens(amount, 0, path, address(this), block.timestamp + 15 minutes);

        } else if (types == TokenType.USDC) {
            IERC20(usdc).transferFrom(msg.sender, address(this), mortgage);
            address[] memory path = new address[](2);
            path[0] = usdc;
            path[1] = tokenAddress;
            amounts = IUniswapV2Router02(uniswapRouter).swapExactTokensForTokens(amount, 0, path, address(this), block.timestamp + 15 minutes);
        }

        uint256 tokenAmount = amounts[1];
        uint256 positionId = positionIdCounter++;

        positions[positionId] = Position({
            types: types,
            owner: msg.sender,
            mortgageAmount: mortgage,
            investAmount: amount,
            tokenAmount: tokenAmount,
            isOpen: true,
            openTime: block.timestamp
        });

        userPositions[msg.sender].push(positionId);
        emit PositionOpened(positionId, msg.sender, mortgage, amount, tokenAmount);
    }

    function close(uint256 positionId) external {
        Position storage position = positions[positionId];
        require(position.isOpen, "Position is already closed");
        require(position.owner == msg.sender, "Not the position owner");

        uint256 fee = (position.investAmount * (block.timestamp - position.openTime)) / 86400;
        TokenType types = position.types;
        uint256 repay = position.investAmount - position.mortgageAmount;
        uint256 received;

        address[] memory path = new address[](2);
        path[0] = tokenAddress;

        if (types == TokenType.ETH) {
            path[1] = IUniswapV2Router02(uniswapRouter).WETH();
            uint256 expected = IUniswapV2Router02(uniswapRouter).getAmountsOut(position.tokenAmount, path)[1];
            if (expected < repay) return vault.repay{value: repay}(types, repay, repay);

            uint[] memory amounts = IUniswapV2Router02(uniswapRouter).swapExactTokensForETH(position.tokenAmount, 0, path, address(this), block.timestamp + 15 minutes);
            received = amounts[1];
            if (received < repay + fee) return vault.repay{value: (repay + fee)}(types, repay + fee, repay);

            uint256 returnAmount = received - fee - repay;
            totalFees += fee;
            position.isOpen = false;
            vault.repay{value: (repay + fee)}(types, repay + fee, repay);
            (bool success, ) = msg.sender.call{value: returnAmount}("");
            require(success, "ETH return failed");
            emit PositionClosed(positionId, msg.sender, returnAmount, fee);

        } else {
            address collateralToken = types == TokenType.USDT ? usdt : usdc;
            path[1] = collateralToken;
            uint256 expected = IUniswapV2Router02(uniswapRouter).getAmountsOut(position.tokenAmount, path)[1];
            if (expected < repay) return vault.repay(types, repay, repay);

            uint[] memory amounts = IUniswapV2Router02(uniswapRouter).swapExactTokensForTokens(position.tokenAmount, 0, path, address(this), block.timestamp + 15 minutes);
            received = amounts[1];
            if (received < repay + fee) return vault.repay(types, repay + fee, repay);

            uint256 returnAmount = received - fee - repay;
            totalFees += fee;
            position.isOpen = false;
            vault.repay(types, repay + fee, repay);
            IERC20(collateralToken).transfer(msg.sender, returnAmount);
            emit PositionClosed(positionId, msg.sender, returnAmount, fee);
        }
    }

    function getUserPositions(address user) external view returns (uint256[] memory) {
        return userPositions[user];
    }

    function withdrawFees() external onlyOwner {
        uint256 feeAmount = totalFees;
        totalFees = 0;
        (bool success, ) = owner().call{value: feeAmount}("");
        require(success, "Fee withdrawal failed");
    }

    receive() external payable {}
}
