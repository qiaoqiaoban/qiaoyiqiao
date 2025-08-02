const { ethers } = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();
  
    console.log("Testing account:", deployer.address);
  
    let val = await ethers.getContractAt("Vault","0x1313B5EBe1CbFFC7721e4acBD302F21aAea378e5");

    let lpeth = await ethers.getContractAt("lps",await val.lpeth());

    let lv = await ethers.getContractAt("QiaoQiaoProtocol","0x8247Fdc8e814A8859ba8E030BeEc1356F30078cd");

    const testController = {
        contractInfo:false,
        depositETH : false,
        whiteList :false,
        leverageBuyETH:true,
        leverageInfo:false,
        leverageSellETH:false,
        withdrawETH : false,
    }

    if(testController.contractInfo)
        {
            console.log("Fetch contractInfo")
            console.log(
                `lpeth :${await val.lpeth()} | lpusdt :${await val.lpusdt()} | lpusdc :${await val.lpusdc()}`
            )
        }
        
    if(testController.depositETH)
    {
        await val.depositETH({value:"500000000000000000"});
        console.log("🍺 Deposite 0.5 ETH")
        
        console.log(
            await lpeth.balanceOf(
                deployer.address
            )
        )
    }

    if(testController.whiteList)
        {
            await val.updateWhiteList("0x8247Fdc8e814A8859ba8E030BeEc1356F30078cd",true);
            console.log("🍺 Update white list")
        }

    if(testController.leverageBuyETH)
        {
            await lv.buy(0,"50000000000000000","100000000000000000",{value:"50000000000000000"});
            console.log("🍺 New position")
        }


    if(testController.leverageInfo)
        {
            const positions = await lv.getUserPositions(deployer.address);
            console.log("🍺 My position :: ",positions)

            console.log(
                await lv.positions(
                    1
                )
            )
        }

    if(testController.leverageSellETH)
        {
            await lv.close(1);
            console.log("🍺 Close position")
        }

    if(testController.withdrawETH)
    {
        // await lpeth.approve(
        //     val.target,
        //     "5000000000000000000"
        // )
        await val.redeem(0,"100000000000000000");
        console.log("🍺 Withdraw 0.01 ETH")
        
        console.log(
            await lpeth.balanceOf(
                deployer.address
            )
        )
    }

  } 
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });

 //npx hardhat run scripts/vaultTestmo.js --network mo