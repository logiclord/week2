pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/poseidon.circom";

template CheckRoot(n) { // compute the root of a MerkleTree of n Levels 
    signal input leaves[2**n];
    signal output root;

    var leaf_len = 2**n;
    var tree_len = (2**(n+1)) - 1;
    var temp[tree_len];

    component poseidon[tree_len - leaf_len];
    
    for(var i = tree_len - 1; i >=0; i--){
        if(i >= tree_len - leaf_len) {
            temp[i] = leaves[i];
        } else {
            poseidon[i] = Poseidon(2);
            poseidon[i].inputs[0] <== temp[2*i+1];
            poseidon[i].inputs[1] <== temp[2*i + 2];
            temp[i] <== poseidon[i].out;
        }
    }
    root <== temp[0];
    //[assignment] insert your code here to calculate the Merkle root from 2^n leaves
}

template MerkleTreeInclusionProof(n) {
    signal input leaf;
    signal input path_elements[n];
    signal input path_index[n]; // path index are 0's and 1's indicating whether the current element is on the left or right
    signal output root; // note that this is an OUTPUT signal

    component poseidon[n];
    var hash = leaf;
    for(var i=0; i < n; i++) {
        poseidon[i] = Poseidon(2);
        //if(path_index[i] == 0) {
        poseidon[i].inputs[0] <== hash + (path_elements[i] - hash) * path_index[i];
        poseidon[i].inputs[1] <== path_elements[i] + (hash - path_elements[i]) * path_index[i];
        hash = poseidon[i].out;
    }

    root <== hash;
}