import { useState } from 'react'
import { ethers, BigNumber } from 'ethers'
import { Box, Flex, Button, Text } from '@chakra-ui/react'
import PitchPFP from './PitchPFP.json'

const PitchPFPAddress = '0xadf4DdA94cB36B562EC6093Fc267094b9d976AFB'

const MainMint = ({ accounts, setAccounts }) => {
  const [mintAmount, setMintAmount] = useState(1)
  const isConnected = Boolean(accounts[0])

  async function handleMint() {
    if (window.ethereum) {
      const provider = new ethers.providers.Web3Provider(window.ethereum)
      const signer = provider.getSigner()
      const contract = new ethers.Contract(
        PitchPFPAddress,
        PitchPFP.abi,
        signer,
      )
      try {
        const response = await contract.mint(BigNumber.from(mintAmount), {
          value: ethers.utils.parseEther((0.001 * mintAmount).toString()),
        })
        console.log('response: ', response)
      } catch (err) {
        console.log('error: ', err)
      }
    }
  }
  return (
    <div>
      {isConnected ? (
        <div>
          <div>
            <Text>{mintAmount} / 100</Text>
          </div>
          <Button onClick={handleMint}>Mint Now</Button>
        </div>
      ) : (
        <Text
          marginTop="50px"
          fontSize="30px"
          fontFamily="inherit"
          textShadow="0 3px #000000"
          color="inherit"
        >
          You must be connected to Mint.
        </Text>
      )}
    </div>
  )
}

export default MainMint
