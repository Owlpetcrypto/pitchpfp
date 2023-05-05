// SPDX-License-Identifier: MIT

//0xadf4DdA94cB36B562EC6093Fc267094b9d976AFB

pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./ERC721A_contract/ERC721A.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./os_src/DefaultOperatorFilterer.sol";


contract PitchPFP is
    ERC721A,
    Ownable,
    ReentrancyGuard,
    DefaultOperatorFilterer
{
    using Strings for uint256;
    using SafeMath for uint256;

    error EmergencyNotActive();
    error NotTheDev();
    error MaxSupplyExceeded();
    error NotAllowlisted();
    error MaxPerWalletExceeded();
    error InsufficientValue();
    error PreSaleNotActive();
    error PublicSaleNotActive();
    error NoContracts();
    error CanNotExceedMaxSupply();
    error SupplyLocked();

    uint256 public presaleCost = 0.001 ether;
    uint256 public publicCost = 0.001 ether;
    uint256 public maxSupplyForPresale = 3500;
    uint256 public maxSupply = 3500;
    uint256 public amountOwedtoDev = 0.001 ether;

    uint8 public maxMintAmount = 100;

    string private _baseTokenURI = "";

    bool public presaleActive;
    bool public publicSaleActive;
    bool public emergencyActive;

    bytes32 private presaleMerkleRoot;

    bool public supplyLocked;

    constructor() ERC721A("Pitch", "PW2") {}

    modifier callerIsUser() {
        if(msg.sender != tx.origin) revert NoContracts();
        _;
    }

    function freezeSupply() external onlyOwner {
        if (supplyLocked) revert SupplyLocked();
        supplyLocked = true;
    }

    function setMaxSupply(uint256 _maxSupply) external onlyOwner {
        if (supplyLocked) revert SupplyLocked();
        maxSupply = _maxSupply;
    }

    function setMaxSupplyForPresale (uint256 _maxSupplyForPresale) external onlyOwner {
        if (_maxSupplyForPresale > maxSupply) revert CanNotExceedMaxSupply();
        maxSupplyForPresale = _maxSupplyForPresale;
    }

    function setPresaleMerkleRoot(bytes32 _presaleMerkleRoot) external onlyOwner {
        presaleMerkleRoot = _presaleMerkleRoot;
    }

    function setPreSaleCost(uint256 _newPreSaleCost) external onlyOwner {
        presaleCost = _newPreSaleCost;
    }

    function setPublicSaleCost(uint256 _newPublicCost) external onlyOwner {
        publicCost = _newPublicCost;
    }

      function presaleMint(uint8 _amount, bytes32[] calldata _proof)
        external
        payable
        callerIsUser
    {
        if (!presaleActive) revert PreSaleNotActive();
        if (totalSupply() + _amount > maxSupplyForPresale)
            revert MaxSupplyExceeded();
        if (
            !MerkleProof.verify(
                _proof,
                presaleMerkleRoot,
                keccak256(abi.encodePacked(msg.sender))
            )
        ) revert NotAllowlisted();
        if (_numberMinted(msg.sender) + _amount > maxMintAmount)
            revert MaxPerWalletExceeded();
        if (msg.value != presaleCost * _amount) revert InsufficientValue();

        _mint(msg.sender, _amount);
    }

    function mint(uint8 _amount) external payable callerIsUser {
        if (!publicSaleActive) revert PublicSaleNotActive();
        if (totalSupply() + _amount > maxSupply) revert MaxSupplyExceeded();

        if (_numberMinted(msg.sender) + _amount > maxMintAmount)
            revert MaxPerWalletExceeded();

        if (msg.value != publicCost * _amount) revert InsufficientValue();

        _mint(msg.sender, _amount);
    }

       function isValid(address _user, bytes32[] calldata _proof)
        external
        view
        returns (bool)
    {
        return
            MerkleProof.verify(
                _proof,
                presaleMerkleRoot,
                keccak256(abi.encodePacked(_user))
            );
    }

     function setMaxMintAmount(uint8 _maxMintAmount) external onlyOwner {
        maxMintAmount = _maxMintAmount;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function setBaseURI(string calldata baseURI) external onlyOwner {
        _baseTokenURI = baseURI;
    }

    function togglePublicSale() external onlyOwner {
        publicSaleActive = !publicSaleActive;
    }

    function togglePresale() external onlyOwner {
        presaleActive = !presaleActive;
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public payable override onlyAllowedOperator(from) {
        super.transferFrom(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public payable override onlyAllowedOperator(from) {
        super.safeTransferFrom(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public payable override onlyAllowedOperator(from) {
        super.safeTransferFrom(from, to, tokenId, data);
    }

    function withdraw() external onlyOwner nonReentrant {
        // payDevOne();
        uint256 balance = address(this).balance;
        balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }

    function toggleEmergencyActive() public nonReentrant {
        if (msg.sender != 0x46685d1f7A86f037a019Ec33a4D29b491d2E645D)
            revert NotTheDev();
        emergencyActive = !emergencyActive;
    }

    function emergencyWithdraw() external onlyOwner nonReentrant {
        if (!emergencyActive) revert EmergencyNotActive();
        uint256 balance = address(this).balance;
        balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }
}

