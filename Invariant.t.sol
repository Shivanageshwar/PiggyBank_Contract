// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "forge-std/Test.sol";
import "../../src/PiggyBank.sol";
import "./Handler.sol";

contract PiggyBankInvariant is Test {
    PiggyBank piggy;
    Handler handler;

    address owner = address(this);
    address attacker = address(0xBEEF);

    uint256 constant LOCK_TIME = 3 days;

    function setUp() public {
        piggy = new PiggyBank(LOCK_TIME);

        vm.deal(owner, 100 ether);
        vm.deal(attacker, 100 ether);

        handler = new Handler(piggy, owner, attacker);

        // Tell Foundry to fuzz Handler instead of this contract
        targetContract(address(handler));
    }

    /* ----------------------------- */
    /* INVARIANTS                    */
    /* ----------------------------- */

    /// Invariant 1:
    /// ETH in contract must always equal internal accounting
    function invariant_balanceMatchesAccounting() public {
        assertEq(address(piggy).balance, piggy.balance());
    }

    /// Invariant 2:
    /// Attacker must never receive ETH
    function invariant_attackerNeverGetsETH() public {
        assertEq(attacker.balance, 100 ether);
    }

    /// Invariant 3:
    /// Only owner can ever receive withdrawn ETH
    function invariant_onlyOwnerGetsFunds() public {
        assertLe(owner.balance, 100 ether + address(piggy).balance);
    }

    /// Invariant 4:
    /// If balance is zero, contract must hold zero ETH
    function invariant_zeroBalanceMeansEmptyContract() public {
        if (piggy.balance() == 0) {
            assertEq(address(piggy).balance, 0);
        }
    }
}
