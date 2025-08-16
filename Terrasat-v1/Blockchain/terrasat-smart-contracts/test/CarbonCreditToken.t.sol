// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/CarbonCreditToken.sol";

contract CarbonCreditTokenTest is Test {
    CarbonCreditToken token;

    function setUp() public {
        token = new CarbonCreditToken();
    }

    function testMint() public {
        token.mint("proj-1", 2025, "Reforestation", "0xabc123", 100);
        CarbonCreditToken.Credit memory credit = token.getCredit(0);
        assertEq(credit.vintage, 2025);
    }
}

























