require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config()
/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.27",
  networks: {
    pol: {
      url: `https://polygon.llamarpc.com`,
      accounts: [process.env.SK],
    },
    mo: {
      url: `https://testnet-rpc.monad.xyz`,
      accounts: [process.env.SK],
    },
  },
};
