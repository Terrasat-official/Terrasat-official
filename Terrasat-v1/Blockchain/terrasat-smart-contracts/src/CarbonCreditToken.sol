// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract CarbonCreditToken {
    struct Credit {
        string projectId;
        uint256 vintage;
        string creditType;
        string verificationHash;
        uint256 quantity;
        bool retired;
    }

    mapping(uint256 => Credit) public credits;
    uint256 public nextTokenId;

    event Minted(uint256 indexed tokenId, string projectId, string creditType);
    event Retired(uint256 indexed tokenId);


    function mint(
        string memory projectId,
        uint256 vintage,
        string memory creditType,
        string memory verificationHash,
        uint256 quantity
    ) public {
        credits[nextTokenId] = Credit(projectId, vintage, creditType, verificationHash, quantity, false);
        emit Minted(nextTokenId, projectId, creditType);
        nextTokenId++;
    }

    function retire(uint256 tokenId) public {
        credits[tokenId].retired = true;
        emit Retired(tokenId);
    }

    function getCredit(uint256 tokenId) public view returns (Credit memory) {
        return credits[tokenId];
    }
}






















