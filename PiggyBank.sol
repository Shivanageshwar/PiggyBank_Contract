// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract PiggyBank {
    // --- Errors ---
    error NotOwner();
    error ZeroDeposit();
    error NothingToWithdraw();
    error LockTimeNotOver();

    // --- State ---
    address public immutable owner;
    uint256 public balance;
    uint256 public depositTime;
    uint256 public immutable lockTime;

    // --- Constructor ---
    constructor(uint256 _lockTimeInSeconds) {
        owner = msg.sender;
        lockTime = _lockTimeInSeconds;
    }

    // --- Modifier ---
    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    // --- Deposit ETH ---
    function deposit() external payable onlyOwner {
        if (msg.value == 0) revert ZeroDeposit();

        balance += msg.value;
        depositTime = block.timestamp;
    }

    // --- Withdraw ETH after lockTime ---
    function withdraw() external onlyOwner {
        if (balance == 0) revert NothingToWithdraw();
        if (block.timestamp < depositTime + lockTime) revert LockTimeNotOver();

        uint256 amount = balance;
        balance = 0;

        payable(owner).transfer(amount);
    }

    // --- Check Time Left ---
    function timeLeft() external view returns (uint256) {
        if (block.timestamp >= depositTime + lockTime) return 0;
        return (depositTime + lockTime) - block.timestamp;
    }
}
