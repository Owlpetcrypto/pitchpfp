import { useState } from 'react'
import './App.css'
import MainMint from './MainMint'
import NavBar from './NavBar'

function App() {
  //changes in UI everytime accounts changes useState will know
  const [accounts, setAccounts] = useState([])
  return (
    <div className="overlay">
      <div className="App">
        <NavBar accounts={accounts} setAccounts={setAccounts} />
        <MainMint accounts={accounts} setAccounts={setAccounts} />
      </div>
      <div className="background"></div>
    </div>
  )
}

export default App
