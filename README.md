# 🐷 PiggyBank Smart Contract (Solidity)

A simple time-locked piggy bank smart contract built in **Solidity 0.8.x**.  
Only the owner can deposit and withdraw. Withdrawal is allowed **after the lock time** has passed.

---

## 🚀 Features

- Owner-only deposit and withdraw
- Adjustable lock time (in seconds)
- Safe ETH handling
- Uses **custom errors** for gas efficiency
- Tracks:
  - `balance`
  - `depositTime`
  - `lockTime`

---

## 📄 How It Works

### 1️⃣ Deploy
Provide a lock time (in seconds):

```solidity
constructor(uint256 _lockTimeInSeconds)
