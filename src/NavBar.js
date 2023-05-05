import { Box, Flex, Button, Link } from '@chakra-ui/react'
import React from 'react'

const NavBar = ({ accounts, setAccounts }) => {
  const isConnected = Boolean(accounts[0])

  async function connectAccount() {
    if (window.ethereum) {
      const accounts = await window.ethereum.request({
        method: 'eth_requestAccounts',
      })
      setAccounts(accounts)
    }
  }

  return (
    <div>
      {/* Connect */}
      {isConnected ? (
        <Box margin="0 30px">Connect</Box>
      ) : (
        <Button onClick={connectAccount}>Connect</Button>
      )}
    </div>
  )
}

export default NavBar
