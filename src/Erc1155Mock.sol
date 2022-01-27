// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.11;

import "solmate/tokens/ERC1155.sol";

contract Erc1155Mock is ERC1155 {

    constructor() {
        
    }

    function mint(address to, uint id, uint amount) public {
        _mint(to, id, amount, "");
    }

    function uri(uint256 id) public override view returns(string memory) {
        return "ipfs";
    }
}