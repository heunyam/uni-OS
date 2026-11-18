# pidstat -h -u -w -C php-fpm 1 (example)
#   # Time     UID   PID  %usr %system %guest %wait  %CPU CPU cswch/s nvcswch/s Command
#   21:39:54     0   812  0.00   0.00   0.00   0.00  0.00   0    0.00      0.00 php-fpm   <- master (skip)
#   21:39:54    48   901  7.00   1.00   0.00  40.00  8.00   1    3.00     25.00 php-fpm
#   21:39:54    48   902  6.00   2.00   0.00  38.00  8.00   0    4.00     22.00 php-fpm

# pidstat columns:
# 1: Time
# 2: UID (48 = apache worker)
# 3: PID
# 4: %usr
# 5: %system
# 6: %guest
# 7: %wait -> "CPU_WAIT"
# 8: %CPU
# 9: CPU
# 10: cswch/s
# 11: nvcswch/s -> "NVCSW"
# 12: Command

# output (example):
#   worker_max=12
#   cpu_wait_avg=39.0
#   nvcsw_avg=280.5
# $1 = measurement time (s)

avg() { awk '{sum += $1} END {printf "%.1f", sum / NR}'; }

DATA=$(pidstat -h -u -w -C php-fpm 1 "$1" | awk '$2 == 48')

WORKER_MAX=$(echo "$DATA" | awk '{print $1}' | uniq -c | sort -n | tail -1 | awk '{print $1}')
CPU_WAIT=$(echo "$DATA" | awk '{print $7}' | avg)
NVCSW=$(echo "$DATA" | awk '{nv[$1] += $11} END {for (t in nv) print nv[t]}' | avg)

echo "worker_max=$WORKER_MAX"
echo "cpu_wait_avg=$CPU_WAIT"
echo "nvcsw_avg=$NVCSW"
