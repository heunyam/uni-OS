#!/bin/bash
cd "$(dirname "$0")"

# .env
source .env
export URL AUTH DURATION

# share one ssh connection, not on windows
SSH="ssh -p $SSH_PORT -o LogLevel=ERROR -o ServerAliveInterval=10 -o ServerAliveCountMax=4"
if [[ $OSTYPE != msys* && $OSTYPE != cygwin* ]]; then
  SSH="$SSH -o ControlMaster=auto -o ControlPath=/tmp/ssh-%C -o ControlPersist=120"
fi
SSH="$SSH $HOST"
LOG="logs/result_$(date +%Y%m%d_%H%M%S).log"
mkdir -p tmp logs

# Environment (once)
echo "Collecting Linux environment data..."
$SSH 'bash -s' < measure_env.sh > tmp/env.out

# Summary header
echo "Parallel Runnable(avg) CPU_Wait(%) Throughput(req/s) Latency(p50/s) Latency(p99/s)" > tmp/summary.out

for PARALLEL in 1 4 8 12 16; do
  export PARALLEL
  echo
  echo "===== Test Case: --parallel-max $PARALLEL ====="

  # 1. Server measurement
  echo "Starting server measurement (vmstat, pidstat ${DURATION}s)..."
  $SSH "bash -s $DURATION" < measure_vmstat.sh  > tmp/vmstat.out &
  $SSH "bash -s $DURATION" < measure_pidstat.sh > tmp/pidstat.out &
  sleep 2

  # 2. Load
  echo "Sending POST load (parallel $PARALLEL)..."
  START=$SECONDS
  bash curl.sh > tmp/curl.out
  ELAPSED=$((SECONDS - START))
  echo "Waiting for server measurement to finish..."
  wait

  # 3. Result
  echo "Building result..."
  bash measure_request.sh "$ELAPSED" < tmp/curl.out > tmp/request.out
  { 
    echo "=================================================="; 
    echo "[RESULT] Parallel: $PARALLEL (Duration: ${DURATION}s)"; 
    echo "=================================================="; 
    bash data.sh; echo; 
  } >> "$LOG"

  # summary row ("-" if data is missing)
  unset runnable_avg cpu_wait_avg throughput latency_p50 latency_p99
  source tmp/vmstat.out; 
  source tmp/pidstat.out; 
  source tmp/request.out
  echo "$PARALLEL ${runnable_avg:--} ${cpu_wait_avg:--} ${throughput:--} ${latency_p50:--} ${latency_p99:--}" >> tmp/summary.out

  sleep 5    # cool down
done

# Summary
{ 
  echo "[SUMMARY]"; 
  column -t tmp/summary.out; 
} >> "$LOG"
echo "Done. Result saved to $LOG"
