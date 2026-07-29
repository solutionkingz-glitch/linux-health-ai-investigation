#!/bin/bash

# ==========================================

# Linux Server Operational Health Check

# ==========================================

set -u

# Exit codes

HEALTHY=0
WARN=1
FAIL=2

# Thresholds

DISK_WARNING=80
DISK_CRITICAL=90

MEMORY_WARNING=20
MEMORY_CRITICAL=10

INODE_WARNING=80
INODE_CRITICAL=90

LOAD_WARNING=2.0
LOAD_CRITICAL=4.0

OVERALL_STATUS=$HEALTHY
# Diagnostic report configuration
REPORT_DIR="/home/ubuntu/diagnostic-reports"
REPORT_FILE="$REPORT_DIR/diagnostic-$(date +%F-%H%M%S).txt"

# Incident state tracking
STATE_FILE="/home/ubuntu/.health_state"
# Create state file if it doesn't exist
if [ ! -f "$STATE_FILE" ]; then
    echo "HEALTHY" > "$STATE_FILE"
fi

PREVIOUS_STATE=$(cat "$STATE_FILE")
echo "=========================================="
echo "     LINUX SERVER HEALTH CHECK"
echo "=========================================="
echo "Hostname: $(hostname)"
echo "Date:     $(date)"
echo "=========================================="

# ------------------------------------------

# 1. Check Nginx service

# ------------------------------------------

echo ""
echo "[1/10] Checking Nginx service..."

if systemctl is-active --quiet nginx; then
echo "PASS: Nginx is running"
else
echo "FAIL: Nginx is not running"
OVERALL_STATUS=$FAIL
fi

# ------------------------------------------

# 2. Check port 80

# ------------------------------------------

echo ""
echo "[2/10] Checking port 80..."

if ss -tulnp | grep -q ':80'; then
echo "PASS: Port 80 is listening"
else
echo "FAIL: Port 80 is not listening"
OVERALL_STATUS=$FAIL
fi

# ------------------------------------------

# 3. Check local application response

# ------------------------------------------

echo ""
echo "[3/10] Checking local application response..."

HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 http://localhost)

if [[ "$HTTP_STATUS" =~ ^2[0-9][0-9]$ ]]; then
echo "PASS: Application responded with HTTP $HTTP_STATUS"
elif [[ "$HTTP_STATUS" =~ ^3[0-9][0-9]$ ]]; then
echo "WARN: Application returned HTTP $HTTP_STATUS"

```
if [[ "$OVERALL_STATUS" -eq "$HEALTHY" ]]; then
    OVERALL_STATUS=$WARN
fi
```

else
echo "FAIL: Application returned HTTP $HTTP_STATUS"
OVERALL_STATUS=$FAIL
fi

# ------------------------------------------
# 4. Check CPU load
# ------------------------------------------

echo ""
echo "[4/10] Checking CPU load..."

LOAD_1=$(awk '{print $1}' /proc/loadavg)
CPU_CORES=$(nproc)

echo "1-minute load average: $LOAD_1"
echo "CPU cores: $CPU_CORES"

CPU_STATUS=$(awk -v avg="$LOAD_1" -v cores="$CPU_CORES" \
    'BEGIN { print avg / cores }')

if awk -v usage="$CPU_STATUS" -v critical="$LOAD_CRITICAL" \
    'BEGIN { exit !(usage >= critical) }'; then

    echo "FAIL: CPU load is critically high"
    OVERALL_STATUS=$FAIL

elif awk -v usage="$CPU_STATUS" -v warning="$LOAD_WARNING" \
    'BEGIN { exit !(usage >= warning) }'; then

    echo "WARN: CPU load is high"

    if [[ "$OVERALL_STATUS" -eq "$HEALTHY" ]]; then
        OVERALL_STATUS=$WARN
    fi

else
    echo "PASS: CPU load is healthy"
fi

# ------------------------------------------

# 5. Check available memory

# ------------------------------------------

echo ""
echo "[5/10] Checking available memory..."

MEMORY_AVAILABLE=$(free | awk '/Mem:/ {printf "%.0f", ($7/$2) * 100}')

echo "Available memory: ${MEMORY_AVAILABLE}%"

if [ "$MEMORY_AVAILABLE" -le "$MEMORY_CRITICAL" ]; then
echo "FAIL: Available memory is critically low"
OVERALL_STATUS=$FAIL
elif [ "$MEMORY_AVAILABLE" -le "$MEMORY_WARNING" ]; then
echo "WARN: Available memory is low"

```
if [[ "$OVERALL_STATUS" -eq "$HEALTHY" ]]; then
    OVERALL_STATUS=$WARN
fi
```

else
echo "PASS: Available memory is healthy"
fi

# ------------------------------------------

# 6. Check disk usage

# ------------------------------------------

echo ""
echo "[6/10] Checking disk usage..."

DISK_USAGE=$(df / | awk 'NR==2 {gsub("%",""); print $5}')

echo "Disk usage: ${DISK_USAGE}%"

if [ "$DISK_USAGE" -ge "$DISK_CRITICAL" ]; then
echo "FAIL: Disk usage is critically high"
OVERALL_STATUS=$FAIL
elif [ "$DISK_USAGE" -ge "$DISK_WARNING" ]; then
echo "WARN: Disk usage is high"

```
if [[ "$OVERALL_STATUS" -eq "$HEALTHY" ]]; then
    OVERALL_STATUS=$WARN
fi
```

else
echo "PASS: Disk usage is healthy"
fi

# ------------------------------------------

# 7. Check inode usage

# ------------------------------------------

echo ""
echo "[7/10] Checking inode usage..."

INODE_USAGE=$(df -i / | awk 'NR==2 {gsub("%",""); print $5}')

echo "Inode usage: ${INODE_USAGE}%"

if [ "$INODE_USAGE" -ge "$INODE_CRITICAL" ]; then
echo "FAIL: Inode usage is critically high"
OVERALL_STATUS=$FAIL
elif [ "$INODE_USAGE" -ge "$INODE_WARNING" ]; then
echo "WARN: Inode usage is high"

```
if [[ "$OVERALL_STATUS" -eq "$HEALTHY" ]]; then
    OVERALL_STATUS=$WARN
fi
```

else
echo "PASS: Inode usage is healthy"
fi

# ------------------------------------------

# 8. Check failed system services

# ------------------------------------------

echo ""
echo "[8/10] Checking failed system services..."

FAILED_SERVICES=$(systemctl --failed --no-legend --no-pager | wc -l)

if [ "$FAILED_SERVICES" -eq 0 ]; then
echo "PASS: No failed system services"
else
echo "WARN: $FAILED_SERVICES failed system service(s)"
systemctl --failed --no-pager

```
if [[ "$OVERALL_STATUS" -eq "$HEALTHY" ]]; then
    OVERALL_STATUS=$WARN
fi
```

fi

# ------------------------------------------

# 9. Check recent critical system errors

# ------------------------------------------

echo
echo "[9/10] Checking recent critical system errors..."

ERROR_COUNT=$(sudo journalctl -p err \
    --since "24 hours ago" \
    --no-pager \
    | grep -v "CONSOLE_EVTCHN" \
    | grep -v "^-- Boot" \
    | wc -l)

if [ "$ERROR_COUNT" -gt 0 ]; then
    echo "WARN: $ERROR_COUNT unexpected critical system error(s) found"
    echo "Review with:"
    echo "sudo journalctl -p err --since '24 hours ago'"
    OVERALL_STATUS=$WARN
else
    echo "PASS: No unexpected critical system errors"
fi


# ------------------------------------------
# 10. Check failed SSH login attempts
# ------------------------------------------

echo ""
echo "[10/10] Checking failed SSH login attempts..."

INVALID_USERS=$(sudo journalctl _SYSTEMD_UNIT=ssh.service \
    --since "24 hours ago" \
    --no-pager \
    | grep -c "Invalid user")

FAILED_PASSWORDS=$(sudo journalctl _SYSTEMD_UNIT=ssh.service \
    --since "24 hours ago" \
    --no-pager \
    | grep -c "Failed password")

AUTH_FAILURES=$(sudo journalctl _SYSTEMD_UNIT=ssh.service \
    --since "24 hours ago" \
    --no-pager \
    | grep -c "authentication failure")

TOTAL_SSH_WARNINGS=$((INVALID_USERS + FAILED_PASSWORDS + AUTH_FAILURES))

if [ "$TOTAL_SSH_WARNINGS" -gt 0 ]; then
    echo "INFO: $INVALID_USERS invalid SSH user attempt(s) blocked"
    echo "INFO: $FAILED_PASSWORDS failed password attempt(s) detected"
    echo "INFO: $AUTH_FAILURES authentication failure(s) detected"
    echo "Review with:"
    echo "sudo journalctl _SYSTEMD_UNIT=ssh.service --since '24 hours ago'"


    if [ "$FAILED_PASSWORDS" -gt 0 ] || [ "$AUTH_FAILURES" -gt 0 ]; then
        OVERALL_STATUS=$WARN
    fi
else
    echo "PASS: No suspicious SSH login activity"
fi

# ------------------------------------------

# Final result

# ------------------------------------------

echo ""
echo "=========================================="

case "$OVERALL_STATUS" in
    "$HEALTHY")
        STATUS_TEXT="HEALTHY"
        ;;
    "$WARN")
        STATUS_TEXT="WARNING"
        ;;
    "$FAIL")
        STATUS_TEXT="CRITICAL"
        ;;
esac

echo "OVERALL STATUS: $STATUS_TEXT"
echo "=========================================="
# ------------------------------------------
# Incident State Comparison
# ------------------------------------------

echo "Previous State : $PREVIOUS_STATE"
echo "Current State  : $STATUS_TEXT"
# ------------------------------------------
# Incident Resolution Detection
# ------------------------------------------

if [ "$PREVIOUS_STATE" != "HEALTHY" ] && [ "$STATUS_TEXT" = "HEALTHY" ]; then
    echo ""
    echo "✅ INCIDENT RESOLVED"
    echo "System has returned to a healthy state."
fi
# ------------------------------------------
# Generate Diagnostic Report
# ------------------------------------------

if [ "$STATUS_TEXT" != "HEALTHY" ] && [ "$PREVIOUS_STATE" != "$STATUS_TEXT" ]; then

cat > "$REPORT_FILE" <<EOF
==========================================
LINUX SERVER DIAGNOSTIC REPORT
==========================================

Hostname: $(hostname)
Date: $(date)
Overall Status: $STATUS_TEXT

------------------------------------------
SYSTEM INFORMATION
------------------------------------------
Uptime:
$(uptime)

------------------------------------------
NGINX STATUS
------------------------------------------
$(systemctl status nginx --no-pager)

------------------------------------------
DISK USAGE
------------------------------------------
$(df -h)

------------------------------------------
MEMORY USAGE
------------------------------------------
$(free -h)

------------------------------------------
CPU LOAD
------------------------------------------
$(uptime)

------------------------------------------
FAILED SERVICES
------------------------------------------
$(systemctl --failed --no-pager)

------------------------------------------
RECENT SYSTEM ERRORS
------------------------------------------
$(journalctl -p err --since "24 hours ago" --no-pager)

------------------------------------------
SSH EVENTS
------------------------------------------
$(journalctl _SYSTEMD_UNIT=ssh.service --since "24 hours ago" --no-pager)

EOF

echo "Diagnostic report created:"
echo "$REPORT_FILE"

fi


# ------------------------------------------
# Send SNS Alert (WARNING or CRITICAL only)
# ------------------------------------------

if [ "$STATUS_TEXT" != "HEALTHY" ] && [ "$PREVIOUS_STATE" != "$STATUS_TEXT" ]; then
    aws sns publish \
        --topic-arn "arn:aws:sns:us-east-1:582049328024:LinuxHealthAlerts" \
        --subject "Linux Server Health Alert: $STATUS_TEXT" \
        --message "$(hostname)

Health Status: $STATUS_TEXT

Date: $(date)

Please review the latest health-check log for details."
fi
# Save current state for next run
echo "$STATUS_TEXT" > "$STATE_FILE"
exit "$OVERALL_STATUS"
