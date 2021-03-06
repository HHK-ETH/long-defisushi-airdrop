// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.11;

import {BaseTest, console} from "./base/BaseTest.sol";
import {LongDefiSushiAirdrop, DropData} from "./../LongDefiSushiAirdrop.sol";
import {Erc1155Mock} from "./../Erc1155Mock.sol";

//random test values from /merkle-generator
//Root => 3d288e9ce649b3db2304f8ea072f7964771555dd364dc47de0bebe0da5eff0ec
//Leaf (0, address(1), 2) => 0xad03bc8049690831ed2083674cb521e980100459c94aa5d1b64fa2ce7a9baeb6
//Proof => 0x2e440f19c31d80004c5756cf198c4d58820a4be61b29c0e494a54e7a8f571aaf,0xb3f1a57778f00726c33fc65d15cdb7cab131b264f764ec89da9af1fa0dafcee4

contract LongDefiSushiAirdropTestGas is BaseTest {

    LongDefiSushiAirdrop longDefiSushiAirdrop;
    Erc1155Mock token;
    bytes32[] proofs;

    function setUp() public {
        token = new Erc1155Mock();
        longDefiSushiAirdrop = new LongDefiSushiAirdrop(token);
        token.mint(address(longDefiSushiAirdrop), 0, 100);
        longDefiSushiAirdrop.setDrop(0, 0xb09436ba49eafd4a7686f7ba1881c185ef86c40562996fd6c2e1362fbdaae88e, block.timestamp + 1 days, 0.02 ether);
        proofs.push(0x2e440f19c31d80004c5756cf198c4d58820a4be61b29c0e494a54e7a8f571aaf);
        proofs.push(0xb3f1a57778f00726c33fc65d15cdb7cab131b264f764ec89da9af1fa0dafcee4);
    }

    function testDeploy() public {
        new LongDefiSushiAirdrop(token);
    }

    function testSetDrop() public {
        longDefiSushiAirdrop.setDrop(0, 0xb09436ba49eafd4a7686f7ba1881c185ef86c40562996fd6c2e1362fbdaae88e, block.timestamp + 1 days, 0.02 ether);
    }
    
    function testClaim() public {
        longDefiSushiAirdrop.claim{value: 0.04 ether}(0, address(1), 2, 2, proofs);
    }

    function testTransferOwnership() public {
        longDefiSushiAirdrop.transferOwnership(address(0));
    }
    
    function testWithdraw() public {
        longDefiSushiAirdrop.withdraw();
    }

    fallback() external payable {}
}