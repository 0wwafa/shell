#!/bin/bash

chmod a+x kv2

PIPE=$(mktemp -u)
mkfifo "$PIPE"

# Cleanup function to be called on script exit (even on errors).
cleanup() {
./kv2 receive -k githubshell &>/dev/null || true
}

# Register the cleanup function to run when the script exits.
trap cleanup EXIT

# --- PRE-CLEANUP SECTION ---

cleanup

APP="bash -c 'while true; do ./turnshell -m -l;sleep 2; done'"

eval "$APP" > "$PIPE" &

# Read from the pipe line-by-line.
while IFS= read -r line; do
  ./kv2 send -k githubshell -v "$line"
  echo "Done."
done < "$PIPE"

echo "Application has finished."

# The 'trap' will handle the final cleanup automatically.
