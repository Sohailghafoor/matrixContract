
const hre = require("hardhat");

async function main() {
  // const XGoldProxy = await hre.ethers.getContractFactory("XGoldProxy");
  // const XGoldProxy_ = await XGoldProxy.deploy("0x09858f9bd5c134922f6f2cb022f5b1b1c541efb7");
  // await XGoldProxy_.deployed();
  // console.log(" XGoldProxy_ Contract deployed to:", XGoldProxy_.address);
  const TolMatrixX4 = await hre.ethers.getContractFactory("TolMatrixX4");
  const TolMatrixX4_ = await TolMatrixX4.deploy("0xc25cA3567626a6845103D2CBb5cdcF268Fa4D96A");
  await TolMatrixX4_.deployed();
  console.log(" TolMatrixX4_ Contract deployed to:", TolMatrixX4_.address);
 
  // const TOL_TRX_COMMUNITY = await hre.ethers.getContractFactory("TOL_TRX_COMMUNITY");
  // const TOL_COMMUNITY = await TOL_TRX_COMMUNITY.deploy("0xc25cA3567626a6845103D2CBb5cdcF268Fa4D96A");
  // await TOL_COMMUNITY.deployed();
  // console.log(" TOL_TRX_COMMUNITY Contract deployed to:", TOL_TRX_COMMUNITY.address);
  

  // const ForsageProxy = await hre.ethers.getContractFactory("ForsageProxy");
  // const ForsageContract = await ForsageProxy.deploy();
  // await ForsageContract.deployed();
  // console.log(" Forsage Contract deployed to:", ForsageContract.address);
  
  // const XQoreStorage = await hre.ethers.getContractFactory("XQoreStorage");
  // const XQoreStorageContract = await XQoreStorage.deploy();
  // await XQoreStorageContract.deployed();
  // console.log(" XQoreStorage Contract deployed to:", XQoreStorageContract.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });