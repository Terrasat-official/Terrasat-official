// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/CarbonCreditToken.sol";

contract CarbonTest is Test {
    CarbonCreditToken token;

    function setUp() public {
        token = new CarbonCreditToken();
    }

    function testMint() public {
        token.mint("proj-1", 2025, "Reforestation", "0xabc123", 100);
        CarbonCreditToken.Credit memory credit = token.getCredit(0);
        assertEq(credit.vintage, 2025);
        assertEq(credit.retired, false);
        assertEq(token.totalSupply(), 1);
    }

    function testRetire() public {
        token.mint("proj-1", 2025, "Reforestation", "0xabc123", 100);
        token.retire(0);
        CarbonCreditToken.Credit memory credit = token.getCredit(0);
        assertTrue(credit.retired);
    }

    function testFuzzMint(uint256 x) public {
        string memory projectId = "proj-fuzz";
        string memory creditType = "AvoidedEmissions";
        string memory verificationHash = "0xdeadbeef";

        token.mint(projectId, x, creditType, verificationHash, 50);
        CarbonCreditToken.Credit memory credit = token.getCredit(0);
        assertEq(credit.vintage, x);
    }
}
