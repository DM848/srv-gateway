#!/bin/sh

## generate nginx server
consul-template -once -consul-addr consul-server:8500 \
    -template ./templates/server.conf.ctmpl:/etc/nginx/conf.d/server.conf

# start nginx
nginx -g "daemon off;" &
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start nginx: $status"
  exit $status
fi

# update the nginx conf and make sure nginx is not dead
COUNTER=0
while true; do
    sleep 5
    if [ $COUNTER -eq 10 ] ; then
        COUNTER=0
        ps aux |grep nginx |grep -q -v grep
        PROCESS_1_STATUS=$?
        # If the greps above find anything, they exit with 0 status
        # If they are not both 0, then something is wrong
        if [ $PROCESS_1_STATUS -ne 0 ]; then
            echo "nginx has exited"
            tail -n 10 /var/log/nginx/error.log
            exit 1
        fi
    fi
    COUNTER=$((COUNTER + 1))

    # generate the server.conf
    consul-template -once -consul-addr consul-server:8500 \
        -template ./templates/server.conf.ctmpl:./server.conf

    # only update the conf if there is a change
    cmp -s ./server.conf /etc/nginx/conf.d/server.conf
    RESULT=$?
    if [ $RESULT -eq 0 ]; then
      continue
    fi

    # update conf and reload nginx
    mv ./server.conf /etc/nginx/conf.d/server.conf
    chmod 0600 /etc/nginx/conf.d/server.conf
    echo "updated nginx configuration"

    nginx -s reload
    status=$?
    if [ $status -ne 0 ]; then
      echo "Failed to reload nginx: $status"
    fi

    sleep 5
done