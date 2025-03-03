// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title Interface of ERC-5679 extending ERC-721
 * @dev See https://eips.ethereum.org/EIPS/eip-5679
 * @author Zainan Victor Zhou (@xinbenlv)
 */

// The ERC-165 identifier of this interface is `0xcce39764`.
interface IERC5679EXT721 {
    /**
     * @param to address
     * @param tokenId tokenId
     * @param data data
     */
    function safeMint(
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @param from address
     * @param tokenId tokenId
     * @param data data
     */
    function burn(address from, uint256 tokenId, bytes calldata data) external;
}
