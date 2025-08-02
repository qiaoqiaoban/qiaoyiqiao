async function main() {
    const [deployer] = await ethers.getSigners();
  
    console.log("Deploying contracts with the account:", deployer.address);
  
    // console.log("Account balance:", (await deployer.getBalance()).toString());
  
    //🍺 0xC08D4577472319C2712874928C44AB65bADcD851
    // const Vault = await ethers.getContractFactory("Vault");
    // const vault = await Vault.deploy(
    //     "0xc2132d05d31c914a87c6611c10748aeb04b58e8f", //USDT
    //     "0x3c499c542cef5e3811e1192ce70d8cc03d5c3359" //USDC
    // );
  
    // console.log("🍺 Vault Deploy success :: ",vault.target)

    // 🍺 0x3E795e7203e1D9a74348498EC00BAc6d76b28F1F
    const LT = await ethers.getContractFactory("QiaoQiaoProtocol");
    const lt = await LT.deploy(
        "0xa5e0829caced8ffdd4de3c43696c57f7d7a678ff", //Quickswap router
        "0x7ceb23fd6bc0add59e62ac25578270cff1b9f619", //WBTC 0x1BFD67037B42Cf73acF2047067bd4F2C47D9BfD6 || WETH 0x7ceb23fd6bc0add59e62ac25578270cff1b9f619
        "0xc2132d05d31c914a87c6611c10748aeb04b58e8f", //USDT
        "0x3c499c542cef5e3811e1192ce70d8cc03d5c3359", //USDC
        "0xC08D4577472319C2712874928C44AB65bADcD851"//vault.target
    );
    console.log("🍺 Pair Deploy success :: ",lt.target)
    
  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });

    //npx hardhat run scripts/deploy.js --network pol