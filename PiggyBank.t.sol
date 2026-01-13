// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "forge-std/Test.sol";
import "../PiggyBank.sol";

contract PiggyBankTest is Test {
    PiggyBank piggy;

    address owner = address(this);
    address attacker = address(0xBEEF);

    uint256 constant LOCK_TIME = 7 days;

    function setUp() public {
        piggy = new PiggyBank(LOCK_TIME);
        vm.deal(owner, 100 ether);
        vm.deal(attacker, 100 ether);
    }

    /* ----------------------------- */
    /* Deposit tests                 */
    /* ----------------------------- */

    function testDeposit() public {
        piggy.deposit{value: 1 ether}();

        assertEq(piggy.balance(), 1 ether);
        assertEq(piggy.depositTime(), block.timestamp);
    }

    function testDepositZeroReverts() public {
        vm.expectRevert(PiggyBank.ZeroDeposit.selector);
        piggy.deposit{value: 0}();
    }

    function testOnlyOwnerCanDeposit() public {
        vm.prank(attacker);
        vm.expectRevert(PiggyBank.NotOwner.selector);
        piggy.deposit{value: 1 ether}();
    }

    /* ----------------------------- */
    /* Withdraw tests                */
    /* ----------------------------- */

    function testCannotWithdrawBeforeLockTime() public {
        piggy.deposit{value: 2 ether}();

        vm.expectRevert(PiggyBank.LockTimeNotOver.selector);
        piggy.withdraw();
    }

    function testWithdrawAfterLockTime() public {
        piggy.deposit{value: 3 ether}();

        vm.warp(block.timestamp + LOCK_TIME);

        uint256 ownerBalanceBefore = owner.balance;
        piggy.withdraw();

        assertEq(owner.balance - ownerBalanceBefore, 3 ether);
        assertEq(piggy.balance(), 0);
    }

    function testWithdrawWithoutDepositReverts() public {
        vm.expectRevert(PiggyBank.NothingToWithdraw.selector);
        piggy.withdraw();
    }

    function testOnlyOwnerCanWithdraw() public {
        piggy.deposit{value: 1 ether}();

        vm.warp(block.timestamp + LOCK_TIME);

        vm.prank(attacker);
        vm.expectRevert(PiggyBank.NotOwner.selector);
        piggy.withdraw();
    }

    /* ----------------------------- */
    /* timeLeft tests                */
    /* ----------------------------- */

    function testTimeLeftReturnsZeroAfterLock() public {
        piggy.deposit{value: 1 ether}();
        vm.warp(block.timestamp + LOCK_TIME);

        assertEq(piggy.timeLeft(), 0);
    }

    function testTimeLeftBeforeLock() public {
        piggy.deposit{value: 1 ether}();
        vm.warp(block.timestamp + 1 days);

        uint256 left = piggy.timeLeft();
        assertGt(left, 0);
        assertLt(left, LOCK_TIME);
    }
}
