// File: contracts/testnet_skaterDAO.sol



// Amended by Jamesy


pragma solidity >=0.7.0 <0.9.0;




contract testnet_skaterDAO is ERC721, Ownable {
  using Strings for uint256;
  using Counters for Counters.Counter;

  Counters.Counter private supply;

  string public uriPrefix = "";
  string public uriSuffix = ".json";
  string public hiddenMetadataUri;
  
  uint256 public cost = 0.0666 ether;
  uint256 public maxSupply = 100;
  uint256 public maxMintAmountPerTx = 5;

  bool public paused = true;
  bool public revealed = false;

  constructor() ERC721("skaterDAO", "SK8") {
    setHiddenMetadataUri("ipfs://QmQ6kjDMGgVLwSbossY743EmuK76dF99pvtwFQjLokPEsE/skaterdao_hidden.json");
  }

  modifier mintCompliance(uint256 _mintAmount) {
    require(_mintAmount > 0 && _mintAmount <= maxMintAmountPerTx, "Tempt Fate Too Many Times And You Will Be the World's Reward");
    require(supply.current() + _mintAmount <= maxSupply, "You Cannot Have So Many");
    _;
  }

  function totalSupply() public view returns (uint256) {
    return supply.current();
  }

  

  function mint(uint256 _mintAmount) public payable mintCompliance(_mintAmount) {
    require(!paused, "All Shall Soon Be Revealed By The Light Of Baphomet");
    require(msg.value >= cost * _mintAmount, "Not Enough SKrill to CHill BIll");

    _mintLoop(msg.sender, _mintAmount);
  }
  
  function mintForAddress(uint256 _mintAmount, address _receiver) public mintCompliance(_mintAmount) onlyOwner {
    _mintLoop(_receiver, _mintAmount);
  }

  function walletOfOwner(address _owner)
    public
    view
    returns (uint256[] memory)
  {
    uint256 ownerTokenCount = balanceOf(_owner);
    uint256[] memory ownedTokenIds = new uint256[](ownerTokenCount);
    uint256 currentTokenId = 1;
    uint256 ownedTokenIndex = 0;

    while (ownedTokenIndex < ownerTokenCount && currentTokenId <= maxSupply) {
      address currentTokenOwner = ownerOf(currentTokenId);

      if (currentTokenOwner == _owner) {
        ownedTokenIds[ownedTokenIndex] = currentTokenId;

        ownedTokenIndex++;
      }

      currentTokenId++;
    }

    return ownedTokenIds;
  }

  function tokenURI(uint256 _tokenId)
    public
    view
    virtual
    override
    returns (string memory)
  {
    require(
      _exists(_tokenId),
      "ERC721Metadata: These are not the Droids you are looking for"
    );

    if (revealed == false) {
      return hiddenMetadataUri;
    }

    string memory currentBaseURI = _baseURI();
    return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI, _tokenId.toString(), uriSuffix))
        : "";
  }

  function setRevealed(bool _state) public onlyOwner {
    revealed = _state;
  }

  function setCost(uint256 _cost) public onlyOwner {
    cost = _cost;
  }

  function setMaxMintAmountPerTx(uint256 _maxMintAmountPerTx) public onlyOwner {
    maxMintAmountPerTx = _maxMintAmountPerTx;
  }

  function setHiddenMetadataUri(string memory _hiddenMetadataUri) public onlyOwner {
    hiddenMetadataUri = _hiddenMetadataUri;
  }

  function setUriPrefix(string memory _uriPrefix) public onlyOwner {
    uriPrefix = _uriPrefix;
  }

  function setUriSuffix(string memory _uriSuffix) public onlyOwner {
    uriSuffix = _uriSuffix;
  }

  function setPaused(bool _state) public onlyOwner {
    paused = _state;
  }

  function withdraw() public onlyOwner {
    // 25% to a treasurey to be allocated by the DAO
    //(bool hs, ) = payable(0x...x).call{value: address(this).balance * 25 / 100}(""); 
    //require(hs);

    // 25% to be deployed to secure the blockchain and garuantee income for the DAO and it's participants
    //(bool hs, ) = payable(0x...x).call{value: address(this).balance * 25 / 100}("");
    //require(hs);

    // 25% to protocol research and development
    //(bool hs, ) = payable(0x...x).call{value: address(this).balance * 25 / 100}("");
    //require(hs);

    // 25% to feed my 2 babies and support their Mother comfortabley. No commisions for txns, just the dream of paying off my student loan debt.
    (bool os, ) = payable(owner()).call{value: address(this).balance}("");
    require(os);

  }

  function _mintLoop(address _receiver, uint256 _mintAmount) internal {
    for (uint256 i = 0; i < _mintAmount; i++) {
      supply.increment();
      _safeMint(_receiver, supply.current());
    }
  }


  function stashPile() public onlyOwner {    
      for (uint256 i = 0; i < 15; i++) {
          supply.increment();
      _safeMint(msg.sender, supply.current());
    }
  }

  function _baseURI() internal view virtual override returns (string memory) {
    return uriPrefix;
  }
}
