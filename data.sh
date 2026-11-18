source tmp/env.out
source tmp/vmstat.out
source tmp/pidstat.out
source tmp/request.out

cat << RESULT

Environment
-----------
CPU Processor          : $cpu vCPU
PHP-FPM Process        : $fpm_worker

Run Queue
---------
Runnable Process (avg / max) : $runnable_avg / $runnable_max

CPU Usage
---------
*User + System Time (avg)    : $usy_avg%
Idle Time (avg)              : $idle_avg%
I/O Wait Time (avg)          : $iowait_avg%

PHP-FPM
-------
Active Worker (max)              : $worker_max
CPU Wait Time (avg)              : $cpu_wait_avg%
Involuntary Context Switch (avg) : $nvcsw_avg /s

Client
------
Request / Failure       : $request / $failure
Throughput              : $throughput request/s
Response Time (p50)     : $p50 s
Response Time (p99)     : $p99 s
RESULT
