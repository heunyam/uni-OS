#   procs -----------memory---------- ---swap-- -----io---- -system-- ------cpu-----
#    r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
#    1  0      0 512340   4120 802100    0    0     5    12  110  210  3  1 96  0  0   <- since boot (skip)
#    9  0      0 511900   4120 802120    0    0     0    40 2100 3900 85 14  1  0  0
#    7  0      0 511880   4120 802130    0    0     0    36 2050 3800 86 13  1  0  0

# vmstat columns:
# 1: r -> "RUNNABLE"
# 2: b
# 3: swpd
# 4: free
# 5: buff
# 6: cache
# 7: si
# 8: so
# 9: bi
# 10: bo
# 11: in
# 12: cs
# 13: us -> "USER_SYSTEM"
# 14: sy -> "USER_SYSTEM"
# 15: id -> "IDLE"
# 16: wa -> "IOWAIT"
# 17: st

# output (example):
#   runnable_avg=8.0
#   runnable_max=9
#   usy_avg=99.0
#   idle_avg=1.0
#   iowait_avg=0.0

# $1 = measurement time (s)

# average of numbers (one per line)
avg() { awk '{sum += $1} END {printf "%.1f", sum / NR}'; }

# Step 1. Raw data (skip 2 header lines + first line = average since boot)
DATA=$(vmstat 1 "$1" | tail -n +4)

# Step 2. Pick columns
RUNNABLE=$(echo "$DATA" | awk '{print $1}')        # r
USER_SYSTEM=$(echo "$DATA" | awk '{print $13 + $14}') # us + sy
IDLE=$(echo "$DATA" | awk '{print $15}')           # id
IOWAIT=$(echo "$DATA" | awk '{print $16}')         # wa

# Step 3. Average / max
echo "runnable_avg=$(echo "$RUNNABLE" | avg)"
echo "runnable_max=$(echo "$RUNNABLE" | sort -n | tail -1)"
echo "usy_avg=$(echo "$USER_SYSTEM" | avg)"
echo "idle_avg=$(echo "$IDLE" | avg)"
echo "iowait_avg=$(echo "$IOWAIT" | avg)"
