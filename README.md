# 🛡️ Aurified-NET - Retroid Pocket 5 Edition

> **A secure, auditable rebuild of the original "[SPPH ULTRA NET](https://github.com/SPPHOfficial/SPPH-ULTRA-NET)" Magisk module.**  
> *Removes obfuscated code, eliminates security risks, and optimizes network latency for handheld gaming.*

![License](https://img.shields.io/badge/License-MIT-blue.svg)
![Platform](https://img.shields.io/badge/Platform-Android%2013%2B-green.svg)
![Device](https://img.shields.io/badge/Device-Retroid%20Pocket%205-orange.svg)
![Status](https://img.shields.io/badge/Status-Stable-success.svg)

## ⚠️ Why This Fork Exists

The original `SPPH-ULTRA-NET` module contained **heavily obfuscated code** (`eval`, variable concatenation) in its `service.sh` and `system.prop` files. This practice is a major security red flag, as it prevents users from auditing what the module actually does.

**This fork:**
- ✅ **Removes all obfuscation:** Every line of code is transparent and readable.
- ✅ **Eliminates security risks:** No hidden backdoors or malicious payloads.
- ✅ **Focuses on proven optimizations:** Only applies settings that are safe and effective for the Retroid Pocket 5.
- ✅ **Graceful degradation:** If a feature (like BBR) isn't supported by the kernel, it skips it without crashing.

---

## 🚀 Features

### 1. TCP Keepalive Tuning (Verified Working)
Reduces the time it takes to detect dead connections, crucial for online gaming stability.
- `tcp_keepalive_time`: **30s** (Default: 7200s)
- `tcp_keepalive_intvl`: **30s** (Default: 75s)
- `tcp_keepalive_probes`: **3** (Default: 9)

### 2. IRQ Affinity Balancing (Verified Working)
Moves network interrupt handlers (WLAN/ETH) to a dedicated CPU core.
- **Benefit:** Isolates network processing from the main gaming cores, reducing input lag and micro-stutters.

### 3. Connection Tracking Optimization (Verified Working)
Increases the NAT table limit to prevent "Connection Lost" errors during heavy multiplayer sessions.
- `nf_conntrack_max`: **65,536**
- `nf_conntrack_buckets`: **65,536**

### 4. BBR Congestion Control (Conditional)
Attempts to enable **BBR** (Bottleneck Bandwidth and RTT) if the kernel supports it.
- *Note:* If your kernel does not support BBR (common on stock kernels), the module gracefully falls back to `cubic` without errors.

---

## 🛑 Removed Features (Due to Kernel Restrictions)

To ensure stability and prevent errors, the following features from the original module were removed as they failed to apply on the Retroid Pocket 5:
- ❌ **DNS Changes:** `/system/etc/resolver.conf` is read-only on modern Android ROMs.
- ❌ **WiFi Power Save:** The `power_save` sysfs node is missing on this device.
- ❌ **TCP Buffer Tuning:** `tcp_rmem`/`tcp_wmem` writes are ignored by the kernel.
- ❌ **Obfuscated Logic:** All `eval` statements and hidden code blocks.

---

## 📥 Installation

1. **Download** the latest `.zip` release from the [Releases](https://github.com/Aurified-266/Aurified-NET/releases) tab.
2. Open **Magisk Manager** (or KernelSU).
3. Tap **Install** → **Select and Patch a File** (or **Install from Storage**).
4. Select the downloaded `.zip`.
5. **Reboot** your device.

### Verification
After reboot, run the following commands in a terminal (Termux/ADB):

```bash
# Check Keepalive (Should be 30)
cat /proc/sys/net/ipv4/tcp_keepalive_time

# Check Congestion Control (Should be 'bbr' or 'cubic')
cat /proc/sys/net/ipv4/tcp_congestion_control

# View Debug Log
cat /data/local/tmp/net_debug.log
