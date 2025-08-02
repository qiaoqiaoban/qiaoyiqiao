pragma solidity ^0.8.27;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract lps is ERC20 {
    address public owner;
    constructor(
        string memory n,
        string memory s
    ) ERC20(n, s) {
        owner = msg.sender;
    }
    function mint ( uint256 amount , address reciver) public
    {
        require(msg.sender == owner,"permission failed");
        _mint(reciver, amount);
    }
    function burn(uint256 amount) external {
        require(balanceOf(msg.sender) >= amount, "Insufficient balance to burn");
        _burn(msg.sender, amount);
    }
    function burnFrom(uint256 amount,address who) external {
         require(msg.sender == owner,"permission failed");
        _burn(who, amount);
    }
}