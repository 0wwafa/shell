#!/bin/bash

chmod a+x p2p*

PIPE=$(mktemp -u)
mkfifo "$PIPE"

APP="bash -c 'while true; do ./p2psh github4 -q -s -t 0;sleep 2; done'"

eval "$APP" > "$PIPE" &

# Read from the pipe line-by-line.
while IFS= read -r line; do
  sleep 1;
done < "$PIPE"

echo "Application has finished."

