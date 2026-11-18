# input from curl.sh (example)
#   201 0.412
#   201 0.389
#   000 0.000   <- cut by timeout (skip)

# input columns:
# 1: http_code -> "FAILURE" (not 201)
# 2: time_total -> "P50", "P99"

# output (example):
#   request=1520
#   failure=0
#   throughput=95.00
#   p50=0.081
#   p99=0.312
# $1 = load time (s)

# Step 1. Drop unfinished requests (000 = cut by timeout), sort by response time
DATA=$(grep -v '^000' | sort -k2 -n)

# Step 2. Count
REQUEST=$(echo "$DATA" | awk 'END {print NR}')
FAILURE=$(echo "$DATA" | awk '$1 != 201' | awk 'END {print NR}')   # 201 = Created
THROUGHPUT=$(awk -v r="$REQUEST" -v s="$1" 'BEGIN {printf "%.2f", r / s}')

# Step 3. Percentile = the line at that position in the sorted list
P50=$(echo "$DATA" | sed -n "$((REQUEST * 50 / 100))p" | awk '{print $2}')
P99=$(echo "$DATA" | sed -n "$((REQUEST * 99 / 100))p" | awk '{print $2}')

echo "request=$REQUEST"
echo "failure=$FAILURE"
echo "throughput=$THROUGHPUT"
echo "p50=$P50"
echo "p99=$P99"
