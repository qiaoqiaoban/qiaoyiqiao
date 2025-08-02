const {
    time,
    loadFixture,
  } = require("@nomicfoundation/hardhat-toolbox/network-helpers");
  const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
  const { expect } = require("chai");
  
  describe("Vault Test", function () {
    describe("Vault Deployment", function () {
      it("Init", async function () {
        const [addr1 ,addr2,addr3,addr4,addr5,addr6] = await ethers.getSigners();
        console.log("begian")
    
  
        const Vault = (await ethers.getContractFactory("Vault"));
        const vault = await Vault.connect(addr1).deploy(addr1.address,addr2.address);
        console.log("Contract deploy :: ",vault.target)
        const Leverage = (await ethers.getContractFactory("LeverageTrading"));
        const lv = await Leverage.connect(addr1).deploy(addr1.address,addr1.address,addr1.address,addr1.address,addr1.address);
        console.log("Leverage deploy :: ",lv.target)
  
        await vault.connect(addr1).depositETH({value:"100000000000000000000"})

        let lpeth = await ethers.getContractAt("lps",
          await vault.lpeth()
        );

        // console.log(
        //   "ETH LP ::",await lpeth.balanceOf(addr1.address)
        // )
        console.log(
          "ETH LP ::",await lpeth.totalSupply()
        )
        console.log(
          "address2 balance ::",await ethers.provider.getBalance(addr2.address)
        )
        await vault.connect(addr1).updateWhiteList(addr2,true);
        console.log("address2 borrow 1e18 eth")
        await vault.connect(addr2).borrow(0,"10000000000000000000")

        console.log(
          "address2 balance ::",await ethers.provider.getBalance(addr2.address)
        )
        console.log(
          "address3 balance ::",await ethers.provider.getBalance(addr3.address)
        )

        await vault.connect(addr3).depositETH({value:"100000000000000000000"})

        console.log(
          "ETH LP ::",await lpeth.totalSupply()
        )

        console.log(
          "address1 balance ::",await ethers.provider.getBalance(addr1.address)
        )
        await vault.connect(addr2).repay(0,"20000000000000000000","10000000000000000000",{value:"20000000000000000000"})

        await vault.connect(addr1).redeem(0,
          await lpeth.balanceOf(addr1.address)
        )

        console.log(
          "address1 balance ::",await ethers.provider.getBalance(addr1.address)
        )


      });
    });
  });
  