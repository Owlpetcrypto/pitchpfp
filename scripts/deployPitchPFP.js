const hre = require('hardhat')

async function main() {
  const PitchPFP = await hre.ethers.getContractFactory('PitchPFP')
  const pitchPFP = await PitchPFP.deploy()

  await pitchPFP.deployed()

  console.log(`Greeter deployed to: `, pitchPFP.address)
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
