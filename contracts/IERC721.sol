//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC721 {
    //event of transfer NFT ownership from -> to
    event Transfer(address indexed from, address indexed to, uint indexed tokenId);
    //event of permit to dispose NFT
    event Approval(address indexed owner, address indexed approved, uint indexed tokenId);
    //event of permit for operator (NFT marketplace) to dispose all owner's NFTs
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    //get owner's token balance 
    function balanceOf(address owner) external view returns(uint);

    //get NFT's owner
    function ownerOf(uint tokenId) external view returns(address);

    //safe transfer of NFT with chech recipient's ability to accept NFT
    function safeTransferFrom(address from, address to, uint tokenId, bytes calldata data) external;

    //overloadinf of previos funtcion using only 3 arguments
    function safeTransferFrom(address from, address to, uint tokenId) external;

    //simple transfer of NFT
    function transferFrom(address from, address to, uint tokenId) external;

    //set permissions to dispose NFT
    function approve(address to, uint tokenId) external;

    //set dispose option "approved" for operator
    function setApprovalForAll(address operator, bool approved) external;

    //chech: who may dispose NFT
    function getApproved(uint tokenId) external view returns(address);

    //chech: can operator dispose owner's NFT or not
    function isApprovedForAll(address owner, address operator) external view returns(bool);
}