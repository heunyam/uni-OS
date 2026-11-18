# pidstat -h -u -w -U apache -C php-fpm 1 (example)
#   # Time     USER   PID  %usr %system %guest %wait  %CPU CPU cswch/s nvcswch/s Command   <- header (skip)
#   21:39:54 apache   901  7.00   1.00   0.00  40.00  8.00   1    3.00     25.00 php-fpm
#   21:39:54 apache   902  6.00   2.00   0.00  38.00  8.00   0    4.00     22.00 php-fpm

# pidstat columns:
# 1: Time
# 2: USER
# 3: PID
# 4: %usr
# 5: %system
# 6: %guest
# 7: %wait -> "CPU_WAIT"
# 8: %CPU
# 9: CPU
# 10: cswch/s -> "TOTAL_CS"
# 11: nvcswch/s -> "TOTAL_CS"
# 12: Command

# output (example):
#   worker_max=12
#   cpu_wait_avg=39.0
#   total_cs_avg=560.0
# $1 = measurement time (s)

avg() { awk '{sum += $1} END {printf "%.1f", sum / NR}'; }

# -U apache: only worker processes (master is root)
DATA=$(pidstat -h -u -w -U apache -C php-fpm 1 "$1" | awk '$2 == "apache"')

WORKER_MAX=$(echo "$DATA" | awk '{print $1}' | uniq -c | sort -n | tail -1 | awk '{print $1}')
CPU_WAIT=$(echo "$DATA" | awk '{print $7}' | avg)
# total context switch per second (voluntary + involuntary, sum of all workers)
TOTAL_CS=$(echo "$DATA" | awk '{cs[$1] += $10 + $11} END {for (t in cs) print cs[t]}' | avg)

echo "worker_max=$WORKER_MAX"
echo "cpu_wait_avg=$CPU_WAIT"
echo "total_cs_avg=$TOTAL_CS"
