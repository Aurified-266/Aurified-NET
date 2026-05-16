#!/system/bin/sh

# ============================================================================
# Aurified-NET (Retroid Pocket 5 Optimized)
# ============================================================================
# Status: Minimalist. Only applies changes that succeed.
# Verified Working: TCP Keepalive, IRQ Balancing, Conntrack.
# ============================================================================

LOG_FILE=/data/local/tmp/net_debug.log
MODPATH=$MODPATH

# Initialize Log
echo "=== SPPH FINAL LOG START $(date) ===" > $LOG_FILE

# Check Root
if [ "$(id -u)" != "0" ]; then
    echo "[CRITICAL] Not running as root." >> $LOG_FILE
    ui_print "[ERROR] Not running as root!"
    exit 1
fi
echo "[OK] Running as root." >> $LOG_FILE

ui_print "[NET] Applying verified network optimizations..."

# -----------------------------------------------------------------------------
# 1. TCP KEEPALIVE (Verified Working)
# -----------------------------------------------------------------------------
# Faster detection of dead connections (crucial for gaming)
ui_print "[NET] Optimizing TCP Keepalive..."

echo "30" > /proc/sys/net/ipv4/tcp_keepalive_time 2>/dev/null
echo "30" > /proc/sys/net/ipv4/tcp_keepalive_intvl 2>/dev/null
echo "3" > /proc/sys/net/ipv4/tcp_keepalive_probes 2>/dev/null

# Verify
KA_TIME=$(cat /proc/sys/net/ipv4/tcp_keepalive_time 2>/dev/null)
if [ "$KA_TIME" = "30" ]; then
    ui_print "  -> Keepalive Time: 30s (Active)"
    echo "[OK] Keepalive Time set to 30" >> $LOG_FILE
else
    ui_print "  -> Keepalive Time: Failed (Current: $KA_TIME)"
    echo "[FAIL] Keepalive Time failed" >> $LOG_FILE
fi

# -----------------------------------------------------------------------------
# 2. TCP CONGESTION (BBR Check)
# -----------------------------------------------------------------------------
ui_print "[NET] Checking for BBR support..."
AVAIL=$(cat /proc/sys/net/ipv4/tcp_available_congestion_control 2>/dev/null)
echo "[INFO] Available: $AVAIL" >> $LOG_FILE

if echo "$AVAIL" | grep -q "bbr"; then
    echo "bbr" > /proc/sys/net/ipv4/tcp_congestion_control 2>/dev/null
    CURRENT=$(cat /proc/sys/net/ipv4/tcp_congestion_control 2>/dev/null)
    if [ "$CURRENT" = "bbr" ]; then
        ui_print "  -> Congestion Control: BBR (Active)"
        echo "[OK] BBR Enabled" >> $LOG_FILE
    else
        ui_print "  -> Congestion Control: BBR failed (Locked to $CURRENT)"
        echo "[WARN] BBR Locked" >> $LOG_FILE
    fi
else
    ui_print "  -> BBR not supported by kernel. Using Cubic."
    echo "[INFO] BBR not available" >> $LOG_FILE
fi

# -----------------------------------------------------------------------------
# 3. IRQ BALANCING (Gaming Optimization)
# -----------------------------------------------------------------------------
# Move network interrupts off gaming cores to reduce input lag
ui_print "[NET] Optimizing IRQ Affinity..."

for irq in $(find /proc/irq -name "smp_affinity_list" 2>/dev/null); do
    IRQ_NUM=$(echo $irq | cut -d'/' -f4)
    if [ -f "/proc/irq/$IRQ_NUM/name" ]; then
        NAME=$(cat /proc/irq/$IRQ_NUM/name 2>/dev/null)
        if echo "$NAME" | grep -qi "eth\|wlan\|net"; then
            # Move to the last available core (dedicated for background tasks)
            CORE_COUNT=$(nproc 2>/dev/null || echo 6)
            TARGET_CORE=$((CORE_COUNT - 1))
            
            if echo "$TARGET_CORE" > $irq 2>/dev/null; then
                ui_print "  -> Moved IRQ $IRQ_NUM ($NAME) to Core $TARGET_CORE"
                echo "[OK] IRQ $IRQ_NUM moved" >> $LOG_FILE
            fi
        fi
    fi
done

# -----------------------------------------------------------------------------
# 4. CONNECTION TRACKING (NAT Optimization)
# -----------------------------------------------------------------------------
# Prevents NAT table exhaustion during heavy gaming sessions
ui_print "[NET] Adjusting Connection Tracking..."

echo "65536" > /proc/sys/net/netfilter/nf_conntrack_max 2>/dev/null
echo "65536" > /proc/sys/net/netfilter/nf_conntrack_buckets 2>/dev/null

CONN_MAX=$(cat /proc/sys/net/netfilter/nf_conntrack_max 2>/dev/null)
if [ "$CONN_MAX" = "65536" ]; then
    ui_print "  -> Conntrack Max: 65536 (Active)"
    echo "[OK] Conntrack set" >> $LOG_FILE
else
    ui_print "  -> Conntrack: Failed (Current: $CONN_MAX)"
    echo "[FAIL] Conntrack failed" >> $LOG_FILE
fi

# -----------------------------------------------------------------------------
# 5. PERSISTENCE LOOP (Retry 3 times)
# -----------------------------------------------------------------------------
ui_print "[NET] Ensuring persistence..."
for i in 1 2 3; do
    sleep 5
    # Re-apply Keepalive (most likely to be reset)
    echo "30" > /proc/sys/net/ipv4/tcp_keepalive_time 2>/dev/null
    echo "30" > /proc/sys/net/ipv4/tcp_keepalive_intvl 2>/dev/null
done

echo "=== SPPH FINAL LOG END ===" >> $LOG_FILE
ui_print "[NET] Optimization Complete!"
ui_print "Log saved to: /data/local/tmp/net_debug.log"

exit 0
