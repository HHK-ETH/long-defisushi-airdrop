const { MerkleTree } = require('merkletreejs')
const keccak256 = require('keccak256');
const { AbiCoder } = require('ethers/lib/utils');

const dropId = 0;
const amountPerAddr = 2;
const abicoder = new AbiCoder();
const leaves = [
    abicoder.encode(["uint"], [dropId])+'0000000000000000000000000000000000000000'+abicoder.encode(["uint"], [amountPerAddr]).slice(2),
    abicoder.encode(["uint"], [dropId])+'0000000000000000000000000000000000000001'+abicoder.encode(["uint"], [amountPerAddr]).slice(2),
    abicoder.encode(["uint"], [dropId])+'0000000000000000000000000000000000000002'+abicoder.encode(["uint"], [amountPerAddr]).slice(2),
].map(x => keccak256(x))
const tree = new MerkleTree(leaves, keccak256, {sort: true})
const root = tree.getHexRoot()
const leaf = leaves[1]
const proof = tree.getHexProof(leaf)
console.log(tree.getHexLayers());
console.log('Root => '+root);
console.log('Leaf => '+leaf)
console.log('Proof => '+proof)
console.log(tree.verify(tree.getProof(leaf), leaf, root)) // true