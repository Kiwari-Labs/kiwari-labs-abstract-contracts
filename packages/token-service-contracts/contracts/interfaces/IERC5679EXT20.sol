// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

/**
 * @title Interface of ERC-5679 extending ERC-20
 * @author Zainan Victor Zhou (@xinbenlv)
 */

interface IERC5679EXT20 {
    /**
     * @param to address
     * @param amount amount
     * @param data data
     */
    function mint(address to, uint256 amount, bytes calldata data) external;

    /**
     * @param from address
     * @param amount amount
     * @param data data
     */
    function burn(address from, uint256 amount, bytes calldata data) external;
}
