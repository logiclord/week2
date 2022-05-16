//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { PoseidonT3 } from "./Poseidon.sol"; //an existing library to perform Poseidon hash on solidity
import "./verifier.sol"; //inherits with the MerkleTreeInclusionProof verifier contract

contract MerkleTree is Verifier {
    uint256[] public hashes; // the Merkle tree in flattened array form
    uint256 public index = 0; // the current index of the first unfilled leaf
    uint256 public root; // the current Merkle root

    constructor() {
        hashes = [0, 0, 0 , 0, 0, 0, 0, 0, 0 , 0, 0 , 0, 0, 0, 0];
        uint256 i = 6;
        while(true) {
            hashes[i] = PoseidonT3.poseidon([hashes[2*i + 1], hashes[2*i + 2]]);
            if(i == 0) {
                break;
            }
            i--;
        }
        index = 7;
        root = 0;
    }

    function insertLeaf(uint256 hashedLeaf) public returns (uint256) {
        hashes[index] = hashedLeaf;
        uint256 i = index;
        do {
            i = i / 2;
            hashes[i] = PoseidonT3.poseidon([hashes[2*i + 1], hashes[2*i + 2]]);
        } while(i > 0);
        index = index + 1;
    }

    function verify(
            uint[2] memory a,
            uint[2][2] memory b,
            uint[2] memory c,
            uint[1] memory input
        ) public view returns (bool) {
        return Verifier.verifyProof(a, b, c, input);
        // [assignment] verify an inclusion proof and check that the proof root matches current root
    }
}
