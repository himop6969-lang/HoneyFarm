# HimOP HoneyFarm

Mass Honeygain deployer using Docker Sidecar (Tun2Proxy) architecture.
No heavy repos. No zip files. Just 3 files and done.

---

## File Structure

```
HimOP_HoneyFarm/
├── HimOP_HoneyFarm.sh   ← Master script
├── honeygain.txt         ← Your accounts (email:password)
├── proxies.txt           ← Your proxies (http://user:pass@ip:port)
└── README.md             ← This file
```

---

## Setup (First Time)

**Step 1:** Upload this folder to your VPS using MobaXterm or SCP.

**Step 2:** Run the installer (as root):
```bash
sudo bash HimOP_HoneyFarm.sh --install
```
This will: Install Docker, pull Honeygain image, pull Tun2Proxy image, verify TUN device.

**Step 3:** Fill your accounts:
```bash
nano honeygain.txt
```
Format: `email@gmail.com:password` (one per line)

**Step 4:** Fill your proxies:
```bash
nano proxies.txt
```
Format: `http://user:pass@ip:port` (one per line)
> NOTE: 10 proxies are used per account (10 devices per email).
> For 100 accounts → you need 1000 proxies.

---

## Commands

| Command | Description |
|---------|-------------|
| `sudo bash HimOP_HoneyFarm.sh --install` | Install all dependencies |
| `bash HimOP_HoneyFarm.sh --start` | Deploy all accounts as containers |
| `bash HimOP_HoneyFarm.sh --status` | Show live status of all devices |
| `bash HimOP_HoneyFarm.sh --stop` | Stop and remove all HimOP containers |

---

## Container Naming

All containers are prefixed with `HimOP_` so they never clash with your existing Pawns or other containers.

- Proxy container: `HimOP_proxy_0_1` (Account 1, Device 1)
- Honeygain container: `HimOP_hg_0_1` (Account 1, Device 1)

---

## Architecture

```
                ┌─────────────────────────────────┐
                │     HimOP_HoneyFarm.sh           │
                │   (reads honeygain.txt +         │
                │    proxies.txt)                  │
                └────────────┬────────────────────┘
                             │ for each account × 10 proxies
                             ▼
          ┌──────────────────────────────────────┐
          │  HimOP_proxy_X  (Tun2Proxy container)│
          │  Routes all traffic via SOCKS/HTTP   │
          │  proxy transparently                 │
          └────────────┬─────────────────────────┘
                       │ --network=container:proxy
                       ▼
          ┌──────────────────────────────────────┐
          │  HimOP_hg_X  (Honeygain container)   │
          │  All internet → goes through proxy   │
          │  Honeygain sees proxy IP as real IP  │
          └──────────────────────────────────────┘
```
