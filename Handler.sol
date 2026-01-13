// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "PiggyBank.sol";
import "forge-std/Test.sol";

contract Handler is Test {
    PiggyBank public piggy;

    address public owner;
    address public attacker;

    constructor(PiggyBank _piggy, address _owner, address _attacker) {
        piggy = _piggy;
        owner = _owner;
        attacker = _attacker;
    }

    /* ----------------------------- */
    /* Fuzzed Actions (Owner)        */
    /* ----------------------------- */

    function deposit(uint96 amount) public {
        amount = uint96(bound(amount, 1 wei, 10 ether));

        vm.prank(owner);
        piggy.deposit{value: amount}();
    }

    function withdraw() public {
        vm.prank(owner);

        // advance time enough to possibly unlock
        vm.warp(block.timestamp + piggy.lockTime() + 1);

        try piggy.withdraw() {} catch {}
    }

    /* ----------------------------- */
    /* Fuzzed Actions (Attacker)     */
    /* ----------------------------- */

    function attackerDeposit(uint96 amount) public {
        amount = uint96(bound(amount, 1 wei, 10 ether));

        vm.prank(attacker);
        try piggy.deposit{value: amount}() {} catch {}
    }

    function attackerWithdraw() public {
        vm.prank(attacker);
        try piggy.withdraw() {} catch {}
    }
}

