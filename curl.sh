# output: "<http_code> <time_total>" per request

END=$((SECONDS + DURATION - 4))

for i in $(seq "$PARALLEL"); do
  while [ $SECONDS -lt $END ]; do
    curl -s -o /dev/null -w "%{http_code} %{time_total}\n" -u "$AUTH" -X POST "$URL" \
      -d "title=test" -d "content=hello" -d "status=publish"
  done &
done
wait
