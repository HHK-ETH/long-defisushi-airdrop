// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.11;

import {BaseTest, console} from "./base/BaseTest.sol";
import {LongDefiSushiAirdrop, DropData} from "./../LongDefiSushiAirdrop.sol";
import {Erc1155Mock, ERC1155} from "./../Erc1155Mock.sol";

//random test values from /merkle-generator
//Root => 3d288e9ce649b3db2304f8ea072f7964771555dd364dc47de0bebe0da5eff0ec
//Leaf (0, address(1), 2) => 0xad03bc8049690831ed2083674cb521e980100459c94aa5d1b64fa2ce7a9baeb6
//Proof => 0x2e440f19c31d80004c5756cf198c4d58820a4be61b29c0e494a54e7a8f571aaf,0xb3f1a57778f00726c33fc65d15cdb7cab131b264f764ec89da9af1fa0dafcee4

contract LongDefiSushiAirdropTest is BaseTest {

    LongDefiSushiAirdrop longDefiSushiAirdrop;
    Erc1155Mock token;
    bytes32[] proofs;

    function setUp() public {
        token = new Erc1155Mock();
        longDefiSushiAirdrop = new LongDefiSushiAirdrop(token);
        token.mint(address(longDefiSushiAirdrop), 0, 100);
        longDefiSushiAirdrop.setDrop(0, 0xb09436ba49eafd4a7686f7ba1881c185ef86c40562996fd6c2e1362fbdaae88e, block.timestamp + 1 days);
        proofs.push(0x2e440f19c31d80004c5756cf198c4d58820a4be61b29c0e494a54e7a8f571aaf);
        proofs.push(0xb3f1a57778f00726c33fc65d15cdb7cab131b264f764ec89da9af1fa0dafcee4);
    }

    function testSetDrop() public {
        longDefiSushiAirdrop.setDrop(0, 0xb09436ba49eafd4a7686f7ba1881c185ef86c40562996fd6c2e1362fbdaae88e, block.timestamp + 1 days);
        DropData memory data = longDefiSushiAirdrop.dropData(0);
        assertEq(data.expiry, block.timestamp + 1 days);
    }
    
    function testFailSetDrop_notOwner() public {
        vm.prank(address(0));
        longDefiSushiAirdrop.setDrop(0, 0xb09436ba49eafd4a7686f7ba1881c185ef86c40562996fd6c2e1362fbdaae88e, block.timestamp + 1 days);
    }

    function testClaim() public {
        longDefiSushiAirdrop.claim(0, address(1), 2, 2, proofs);
        assertEq(2, token.balanceOf(address(1), 0));
    }

    function testFailClaim_invalidProof() public {
        bytes32[] memory badProofs = new bytes32[](2);
        badProofs[0] = 0x0;
        badProofs[1] = 0xb3f1a57778f00726c33fc65d15cdb7cab131b264f764ec89da9af1fa0dafcee4;
        longDefiSushiAirdrop.claim(0, address(1), 2, 2, badProofs);
    }

    function testFailClaim_dateExpired() public {
        vm.warp(block.timestamp + 2 days);
        longDefiSushiAirdrop.claim(0, address(1), 2, 2, proofs);
    }
    
    function testFailClaim_InvalidAmount() public {
        longDefiSushiAirdrop.claim(0, address(1), 1, 2, proofs);
        longDefiSushiAirdrop.claim(0, address(1), 1, 2, proofs);
        longDefiSushiAirdrop.claim(0, address(1), 1, 2, proofs); //fail on third as 2 is max from setUp
    }

    function testTransferOwnership() public {
        longDefiSushiAirdrop.transferOwnership(address(0));
        (address owner,) = longDefiSushiAirdrop.adminInfos();
        assertEq(owner, address(0));
    }

    function testFailTransferOwnership_notOwner() public {
        vm.prank(address(0));
        longDefiSushiAirdrop.transferOwnership(address(0));
    }
    
    function testSetToken() public {
        longDefiSushiAirdrop.setToken(ERC1155(address(0)));
        (, ERC1155 newToken) = longDefiSushiAirdrop.adminInfos();
        assertEq(address(newToken), address(0));
    }

    function testFailSetToken_notOwner() public {
        vm.prank(address(0));
        longDefiSushiAirdrop.setToken(ERC1155(address(0)));
    }
}