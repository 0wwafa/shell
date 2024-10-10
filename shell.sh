#!/bin/bash
while true
do
echo 'started..'
node shell.js -t 120 -r github3
echo "ended."
sleep 2
done
