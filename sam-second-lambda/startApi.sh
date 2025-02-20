#!/bin/bash

MAX_RETRIES=5
RETRY_INTERVAL=2

start_api() {
  sam local start-api
}

handle_interrupt() {
  echo "Ctrl-c received stop!"
  exit 1
}
trap handle_interrupt SIGINT

for ((i=1; i<=MAX_RETRIES; i++)); do
  echo "Try #$i of $MAX_RETRIES..."
  start_api && break
  if [ $i -lt $MAX_RETRIES ]; then
    echo "Fail. I'll try again in $RETRY_INTERVAL seconds... 🤞"
    sleep $RETRY_INTERVAL
  else
    echo "Failed to start sam local start-api after $MAX_RETRIES attempts. 🤷‍♂️"
    exit 1
  fi
done
