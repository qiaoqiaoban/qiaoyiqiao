
# ⚙️ QQB Protocol

**QQB Protocol** is a secure and flexible leveraged spot trading smart contract framework built on Ethereum. It enables users to open leveraged positions using ETH, USDT, or USDC as collateral and execute token trades through Uniswap V2. All positions are backed by a Vault lending system with customizable liquidation and fee mechanisms.

---

## ✨ Features

- 🔁 **Leverage Long Trading** using ETH / USDT / USDC
- 💰 **Vault Integration** for collateralized borrowing
- ⚖️ **Uniswap V2 Trading** path-based token swaps
- 📊 **Position Tracking** with lifecycle management
- 🛡️ **Collateral Safety Checks** and Liquidation triggers
- 📈 **Dynamic Time-Based Fee Calculation**
- 🧾 **Fee Accumulation & Owner Withdrawal**

---

## 📦 Contract Overview

| Contract        | Description                                                  |
|----------------|--------------------------------------------------------------|
| `qqb_protocol` | Main leveraged trading contract supporting multiple collaterals |
| `IVault`       | External lending contract interface with `borrow` and `repay` |
| `IUniswapV2Router02` | Uniswap V2 Router interface for swaps & pricing       |

---

## 🧩 Supported Tokens

- **Collateral Types**:  
  - `ETH` (native)
  - `USDT` (ERC20)
  - `USDC` (ERC20)

- **Target Token**:  
  - Customizable `tokenAddress` set in constructor

---

## 🛠️ Usage

### Open a Leveraged Position

```solidity
buy(TokenType tokenType, uint256 mortgage, uint256 amount)
````

* `tokenType`: Collateral type (`ETH`, `USDT`, `USDC`)
* `mortgage`: Amount user provides
* `amount`: Total leveraged amount (must not exceed 10x of mortgage)

### Close a Position

```solidity
close(uint256 positionId)
```

* Automatically sells position token back to base asset
* Repays vault debt and returns any remaining to the user

---

## 🔐 Admin Functions

```solidity
withdrawFees()
```

* Allows the contract owner to withdraw accumulated fees

---

## 📚 Events

* `PositionOpened`: Logs new position with all relevant metrics
* `PositionClosed`: Logs closure result including fee and returns

---

## ⚠️ Security Notes

* Access control enforced via `Ownable`
* Positions can only be closed by their original creators
* Time-based fees grow linearly, ensure your frontend warns users
* Reentrancy protection recommended via additional guards

---

## 🧪 Test & Deployment

* Network: Ethereum (or any EVM-compatible chain)
* Dependencies:

  * [OpenZeppelin Contracts](https://github.com/OpenZeppelin/openzeppelin-contracts)
  * [Uniswap V2 Router](https://docs.uniswap.org/)
* Deployment via `Hardhat` / `Foundry` recommended

---

## 📄 License

MIT License.
© 2025 QQB Protocol Contributors.