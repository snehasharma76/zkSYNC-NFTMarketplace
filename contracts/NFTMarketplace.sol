// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFTMarketplace is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    struct NFT {
        uint256 id;
        address creator;
        string uri;
        uint256 price;
        bool forSale;
    }

    mapping(uint256 => NFT) public nfts;

    event NFTMinted(uint256 indexed id, address indexed creator, string uri);
    event NFTListed(uint256 indexed id, uint256 price);
    event NFTPurchased(uint256 indexed id, address indexed buyer);

    constructor() ERC721("zkSYNC NFT Marketplace", "ZNFT") {}

    function mintNFT(string memory uri, uint256 price) public {
        uint256 tokenId = _tokenIdCounter.current();
        _mint(msg.sender, tokenId);
        _setTokenURI(tokenId, uri);

        nfts[tokenId] = NFT(tokenId, msg.sender, uri, price, true);
        _tokenIdCounter.increment();

        emit NFTMinted(tokenId, msg.sender, uri);
    }

    function listNFT(uint256 tokenId, uint256 price) public {
        require(ownerOf(tokenId) == msg.sender, "Not the owner");
        nfts[tokenId].forSale = true;
        nfts[tokenId].price = price;

        emit NFTListed(tokenId, price);
    }

    function purchaseNFT(uint256 tokenId) public payable {
        require(nfts[tokenId].forSale, "NFT not for sale");
        require(msg.value >= nfts[tokenId].price, "Insufficient funds");

        address seller = ownerOf(tokenId);
        _transfer(seller, msg.sender, tokenId);

        nfts[tokenId].forSale = false;
        emit NFTPurchased(tokenId, msg.sender);
        payable(seller).transfer(msg.value);
    }
}
