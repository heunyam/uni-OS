#!/bin/bash
# e.g) bash intervention.sh 2  ->  it changes php-fpm workers count
cd "$(dirname "$0")"
source .env

# commands run on the server
CHANGE="sudo sed -i -e 's/^pm = .*/pm = static/' -e 's/^pm.max_children = .*/pm.max_children = $1/' /etc/php-fpm.d/www.conf"
RESTART="sudo systemctl restart php-fpm"
CHECK="pgrep -u apache -c php-fpm"

echo "[Intervention] pm.max_children = $1"
ssh -t -p "$SSH_PORT" "$HOST" "$CHANGE && $RESTART && echo -n 'worker: ' && $CHECK"
