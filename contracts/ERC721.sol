//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC721.sol";
import "./IERC721Metadata.sol";
import "./IERC721Receiver.sol";
import "./Strings.sol";

contract ERC721 is IERC721Metadata {
    using Strings for uint;
    string private _name;
    string private _symbol;
    mapping(address => uint) private balances;
    mapping(uint => address) private owners;
    mapping(uint => address) private tokenApprovals;
    mapping(address => mapping(address => bool)) private operatorApprovals;

    modifier requireMinted(uint _tokenId) {
        require(_exist(_tokenId), "Owner of token ID  not exist");
        _;
    }

    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() external view returns(string memory) {
        return _name;
    }

    function symbol() external view returns(string memory) {
        return _symbol;
    }

    function balanceOf(address _owner) public view returns(uint) {
        require(_owner != address(0), "Owner can not be zero");
        return balances[_owner];
    }

    function ownerOf(uint _tokenId) public view requireMinted(_tokenId) returns(address) {
        return owners[_tokenId];
    }

    function safeTransferFrom(address _from, address _to, uint _tokenId) public {
        safeTransferFrom(_from, _to, _tokenId, "");
    }

    function safeTransferFrom(address _from, address _to, uint _tokenId, bytes calldata _data) public {
        require(_isAprovedOrOwner(msg.sender, _tokenId), "Not approved or owner");

        _safeTransfer(_from, _to, _tokenId, _data);
    }


    function transferFrom(address _from, address _to, uint _tokenId) external {
        require(_isAprovedOrOwner(msg.sender, _tokenId), "Not approved or owner");

        _transfer(_from, _to, _tokenId);
    }

    function approve(address _to, uint _tokenId) external {
        address _owner = owners[_tokenId];
        require(_owner == msg.sender || isApprovedForAll(_owner, msg.sender), "Can't aprove");
        require(_owner == _to, "Can't approve to self");
        
        tokenApprovals[_tokenId] = _to;

        emit Approval(_owner, _to, _tokenId);
    }

    function setApprovalForAll(address _operator, bool _approved) external {
        require(_operator != msg.sender, "Can't approve to self");

        operatorApprovals[msg.sender][_operator] = _approved;

        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    function getApproved(uint _tokenId) public view requireMinted(_tokenId) returns(address) {
        return tokenApprovals[_tokenId];
    }

    function isApprovedForAll(address _owner, address _operator) public view returns(bool) {
        return operatorApprovals[_owner][_operator];
    }

    function tokenURI(uint _tokenId) external view requireMinted(_tokenId) returns(string memory) {
        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, _tokenId.toString())) : "";
    }

    function _exist(uint _tokenId) internal view returns(bool) {
        return owners[_tokenId] != address(0);
    }

    function _baseURI() internal view virtual returns(string memory) {
        return "";
    }

    function _isAprovedOrOwner(address _spender, uint _tokenId) internal view returns(bool) {
        address _owner = owners[_tokenId];
        return (_spender == _owner || isApprovedForAll(_owner, _spender) || getApproved(_tokenId) == _spender);
    }

    function _transfer(address _from, address _to, uint _tokenId) internal {
        require(owners[_tokenId] == _from, "Not correct NFT's owner");
        require(_to == address(0), "Can't transfer NFT to zero");

        _beforeTokenTransfer(_from, _to, _tokenId);

        delete tokenApprovals[_tokenId];
        balances[_from] --;
        balances[_to] ++;
        owners[_tokenId] = _to;

        emit Transfer(_from, _to, _tokenId);

        _afterTokenTransfer(_from, _to, _tokenId);
    }

    function _safeTransfer(address _from, address _to, uint _tokenId, bytes calldata _data) internal {
        _transfer(_from, _to, _tokenId);
        require(_checkOnERC721Received(_from, _to, _tokenId, _data), "Transfer to non ERC721 receiver");
    }

    function _checkOnERC721Received(address _from, address _to, uint _tokenId, bytes calldata _data) private returns(bool) {
        if (_to.code.length > 0) {
            try IERC721Receiver(_to).onERC721Received(_from, _to, _tokenId, _data) returns(bytes4 response) {
                return response == IERC721Receiver.onERC721Received.selector;
            } catch(bytes memory reason) {
                if (reason.length == 0) {
                    revert("Transfer to non ERC721 receiver");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
        
    }

    function _beforeTokenTransfer(address _from, address _to, uint _tokenId) internal virtual {}

    function _afterTokenTransfer(address _from, address _to, uint _tokenId) internal virtual {}  
}
