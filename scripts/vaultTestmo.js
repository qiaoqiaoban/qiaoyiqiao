const { ethers } = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();
  
    console.log("Testing account:", deployer.address);
  
    let val = await ethers.getContractAt("Vault","0xf4C41330F780875a1e9273e7D5B84A09F567Cc4d");

    let lpeth = await ethers.getContractAt("lps",await val.lpeth());

    let lv = await ethers.getContractAt("LeverageTrading","0xeA315B6a49C3117A16d71B85030FE459C6CA92a9"); 

    const testController = {
        contractInfo:true,
        depositETH : false,
        whiteList :false,
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
            await val.updateWhiteList("0xeA315B6a49C3117A16d71B85030FE459C6CA92a9",true);
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