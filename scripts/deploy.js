const hre = require("hardhat");

async function main() {
  console.log("Deploying Safe Canine Ecosystem...");

  const Kibble = await hre.ethers.getContractFactory("KibbleToken");
  const kibble = await Kibble.deploy();
  await kibble.waitForDeployment();
  console.log("Kibble Token deployed to:", await kibble.getAddress());

  const Puppy = await hre.ethers.getContractFactory("PuppyNFT");
  const puppy = await Puppy.deploy(await kibble.getAddress());
  await puppy.waitForDeployment();
  console.log("Puppy NFT deployed to:", await puppy.getAddress());

  // Transfer ownership of the token to the NFT contract so it can mint rewards
  await kibble.transferOwnership(await puppy.getAddress());
  console.log("Ownership transferred to NFT contract.");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
              
