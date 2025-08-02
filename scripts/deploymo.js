const { ethers } = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();
  
    console.log("Deploying contracts with the account:", deployer.address);
  
    console.log("Account balance:", (await ethers.provider.getBalance(deployer.address)).toString());

    
  //   const tx = await deployer.sendTransaction({
  //     to: "0xB1DF40ECe96D6f9db27Ce60588850baECe35cDC6",
  //     value: 1,
  // });

  // console.log(`Transaction hash: ${tx.hash}`);


    //🍺 0x1313B5EBe1CbFFC7721e4acBD302F21aAea378e5
    // const Vault = await ethers.getContractFactory("Vault");
    // const vault = await Vault.deploy(
    //     "0x7777b6562950c7ad54d0e707aac1f4dca8a8e95a", //USDT
    //     "0xf817257fed379853cde0fa4f97ab987181b1e5ea" //USDC
    // );
    //
    // console.log("🍺 Vault Deploy success :: ",vault.target)

    // 🍺 0xeA315B6a49C3117A16d71B85030FE459C6CA92a9
    const LT = await ethers.getContractFactory("QiaoQiaoProtocol");
    const lt = await LT.deploy(
        "0xc7e09b556e1a00cfc40b1039d6615f8423136df7", //atlantisdex router
        "0xB5a30b0FDc5EA94A52fDc42e3E9760Cb8449Fb37", //WETH 0xB5a30b0FDc5EA94A52fDc42e3E9760Cb8449Fb37 || WETH 0xB5a30b0FDc5EA94A52fDc42e3E9760Cb8449Fb37
        "0xc2132d05d31c914a87c6611c10748aeb04b58e8f", //USDT
        "0x3c499c542cef5e3811e1192ce70d8cc03d5c3359", //USDC
        "0x1313B5EBe1CbFFC7721e4acBD302F21aAea378e5"//vault.target
    );
    console.log("🍺 Pair Deploy success :: ",lt.target)
    
  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });

    //npx hardhat run scripts/deploymo.js --network mo