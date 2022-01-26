// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.11;

import "solmate/tokens/ERC1155.sol";
import "./MerkleProof.sol";

struct DropData {
    bytes32 root;
    uint256 maxClaimDate;
    string link;
}

//ERC1155 for multiple airdrops
contract LongDefiSushiAirdrop is ERC1155 {
    error Error_NotOwner();
    error Error_DateExpired();
    error Error_InvalidAmount();
    error Error_InvalidProof();

    event SetDrop(uint256 indexed id, bytes32 root, uint256 maxClaimDate, string link);
    event Claimed(uint256 indexed id, address indexed to, uint256 amount);

    address public owner;
    //drop id => data
    mapping(uint256 => DropData) public drop;
    //drop id => address => amount claimed
    mapping(uint256 => mapping(address => uint256)) public claimed;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        if (owner != msg.sender) {
            revert Error_NotOwner();
        }
        _;
    }

    function setDrop(uint256 id, bytes32 root, uint256 maxClaimDate, string calldata link) external onlyOwner {
        drop[id] = DropData(root, maxClaimDate, link);

        emit SetDrop(id, root, maxClaimDate, link);
    }

    function claim(uint256 id, address to, uint256 amount, uint256 maxAmount, bytes32[] calldata proof) external {
        DropData memory data = drop[id];
        if (data.maxClaimDate < block.timestamp) {
            revert Error_DateExpired();
        }
        if (claimed[id][to] + amount > maxAmount) {
            revert Error_InvalidAmount();
        }

        bytes32 leaf = keccak256(abi.encodePacked(id, to, maxAmount));
        if (!MerkleProof.verify(proof, data.root, leaf)) {
            revert Error_InvalidProof();
        }

        claimed[id][to] += amount;
        _mint(to, id, amount, "");

        emit Claimed(id, to, amount);
    }

    function transferOwnership(address newOwner) external onlyOwner {
        owner = newOwner;
    }

    function uri(uint256 id) public view override returns (string memory) {
        return drop[id].link;
    }
}
