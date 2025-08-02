const { ethers } = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();
  
    console.log("Testing account:", deployer.address);
  
    let val = await ethers.getContractAt("Vault","0xC08D4577472319C2712874928C44AB65bADcD851");

    let lpeth = await ethers.getContractAt("lps",await val.lpeth());

    let lv = await ethers.getContractAt("LeverageTrading","0x3E795e7203e1D9a74348498EC00BAc6d76b28F1F"); //0xE3D2ac4D44dEb1CD3edA9bf3Dcf74B8Ef12921eC

    const testController = {
        contractInfo:true,
        depositETH : false,
        whiteList :true,
        leverageBuyETH:false,
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
        await val.depositETH({value:"100000000000000000"});
        console.log("🍺 Deposite 0.1 ETH")
        
        console.log(
            await lpeth.balanceOf(
                deployer.address
            )
        )
    }

    if(testController.whiteList)
        {
            await val.updateWhiteList("0xE3D2ac4D44dEb1CD3edA9bf3Dcf74B8Ef12921eC",true);
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

 //npx hardhat run scripts/vaultTest.js --network pol