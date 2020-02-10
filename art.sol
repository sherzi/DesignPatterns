pragma solidity ^0.5.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/IERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/IERC721Receiver.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/SafeMath.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Address.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/drafts/Counters.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/introspection/ERC165.sol";


contract Artist is IERC721 {

    mapping (uint256 => address) private _tokenOwner;
    mapping (uint256 => address) private _tokenApprovals;
    mapping (address => Counters.Counter) private _ownedTokensCount;
    mapping (address => mapping (address => bool)) private _operatorApprovals;
    mapping(uint => ArtWork) artworks;

    address artist;

    constructor() public {
        artist = msg.sender;
        _registerInterface(_InterfaceId_ERC721);

    }
   
    function createArtwork(uint hashIPFS, string memory Name) public returns (ArtWork) {
       ArtWork artContract = new ArtWork(hashIPFS, Name, artist);
       artworks[hashIPFS] = artContract;
       return artContract;
    }

    function checkArtwork(uint hashIPFS) public view returns(bool) {
        if(artworks[hashIPFS] == ArtWork(0x0)) {
            return false;
        }
        return true;  
    }
}

contract ArtWork is IERC721 {

    event Transfer(address indexed from, address indexed to, uint256 tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 tokenId);
    
    mapping (uint256 => address) private _tokenApprovals;
    mapping (uint256 => address) private _tokenOwner;
    mapping (address => mapping (address => bool)) private _operatorApprovals;


    address artist;
    string  name;
    uint  hashIPFS;
    address owner;
    
    constructor(uint ipfsHash, string memory artName, address originalOwner) public {
        artist = msg.sender;
        name = artName;
        hashIPFS = ipfsHash;
        owner = originalOwner;
    }


    function safeTransferFrom(address from, address to, uint256 tokenId) public {
       require(msg.sender == owner, "ERC721: transfer caller is not owner nor approved");
       safeTransferFrom(from, to, tokenId, "");
    }
    

    function approve(address to, uint256 tokenId) public {
        require(to != owner, "ERC721: approval to current owner");
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender),
            "ERC721: approve caller is not owner nor approved for all");
        tokenId = to;
        emit Approval(owner, to, tokenId);
    }   
        
    function getApproved(uint256 tokenId) public view returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");
        return _tokenApprovals[tokenId];
    }

    function _exists(uint256 tokenId) internal view returns (bool) {
        owner = _tokenOwner[tokenId];
        return owner != address(0);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        owner = _tokenOwner[tokenId];
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    function setApprovalForAll(address to, bool approved) public {
        require(to != msg.sender, "ERC721: approve to caller");

        _operatorApprovals[msg.sender][to] = approved;
        emit Approval(msg.sender, to, approved);
    }

    function isApprovedForAll(address owner, address operator) public view returns (bool) {
        return _operatorApprovals[owner][operator];
    }
    
}   