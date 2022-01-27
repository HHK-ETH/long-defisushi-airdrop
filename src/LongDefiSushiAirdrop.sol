// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.11;

import "solmate/tokens/ERC1155.sol";
import "./MerkleProof.sol";

struct DropData {
    bytes32 root;
    uint256 expiry;
    string link;
}

/// @title LongDefiSushiAirdrop
/// @author HHK-ETH
/// @notice Airdrop multiple erc1155 tokens to selected addresses using merkle tree
contract LongDefiSushiAirdrop is ERC1155 {

    /// Errrors

    error Error_NotOwner();
    error Error_DateExpired();
    error Error_InvalidAmount();
    error Error_InvalidProof();

    /// Events

    event SetDrop(uint256 indexed id, bytes32 root, uint256 maxClaimDate, string link);
    event Claimed(uint256 indexed id, address indexed to, uint256 amount);

    /// Variables

    /// @notice owner of the contract
    address public owner;
    /// @notice drop id => data
    mapping(uint256 => DropData) internal drop;
    /// @notice drop id => address => amount claimed
    mapping(uint256 => mapping(address => uint256)) public claimed;

    constructor() {
        owner = msg.sender;
    }

    /// Modifiers

    /// @notice Modifier to make functions callable by owner only
    modifier onlyOwner() {
        if (owner != msg.sender) {
            revert Error_NotOwner();
        }
        _;
    }

    /// State change functions

    /// @notice Edit or add new token Id and airdrop merkle root
    /// @param id Id of the token to edit/add
    /// @param root Merkle root of the airdrop
    /// @param expiry Max date the token can be claimed
    /// @param link Link to the token image/data
    function setDrop(uint256 id, bytes32 root, uint256 expiry, string calldata link) external onlyOwner {
        drop[id] = DropData(root, expiry, link);

        emit SetDrop(id, root, expiry, link);
    }

    /// @notice Claim airdrop using merkle proofs
    /// @param id Id of the token to claim, user to compute the leaf
    /// @param to Address to receive the airdrop, user to compute the leaf
    /// @param amount Amount to claim, user can decide to claim less than deserved amount
    /// @param maxAmount Total amount deserved to the user, used to compute the leaf
    /// @param proof Array of merkle proofs to compute the root
    function claim(uint256 id, address to, uint256 amount, uint256 maxAmount, bytes32[] calldata proof) external {
        DropData memory data = drop[id];
        if (data.expiry < block.timestamp) {
            revert Error_DateExpired();
        }
        
        uint256 totalClaimed = claimed[id][to] + amount;
        if (totalClaimed > maxAmount) {
            revert Error_InvalidAmount();
        }

        bytes32 leaf = keccak256(abi.encodePacked(id, to, maxAmount));
        if (!MerkleProof.verify(proof, data.root, leaf)) {
            revert Error_InvalidProof();
        }

        claimed[id][to] = totalClaimed;
        _mint(to, id, amount, "");

        emit Claimed(id, to, amount);
    }

    /// @notice Transfer ownership of the contract to a new address
    /// @param newOwner New owner of the contract
    function transferOwnership(address newOwner) external onlyOwner {
        owner = newOwner;
    }

    /// View functions

    /// @notice View function to get token image/data link
    /// @param id Id of the token
    /// @return link Returns the link to token image/data
    function uri(uint256 id) public view override returns (string memory link) {
        return drop[id].link;
    }

    /// @notice View function to get token dropData
    /// @param id Id of the token/airdrop
    /// @return data Returns the DropData struct
    function dropData(uint id) public view returns (DropData memory data) {
        return drop[id];
    }
}
