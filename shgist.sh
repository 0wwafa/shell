#!/bin/bash

# --- Configuration ---
YOUR_APP="bash -c 'while true; do date;./turnshell -m -l;sleep 2; done'"

# --- Script ---

# Exit on any error
set -e

# Create a temporary named pipe to redirect the app's output
PIPE=$(mktemp -u)
mkfifo "$PIPE"

# Start the application in the background, with its stdout redirected to the pipe.
# The `eval` is used to correctly execute the command string.
eval "$YOUR_APP" > "$PIPE" &
APP_PID=$!

# Initialize variables
GIST_ID=""
TEMP_FILE=$(mktemp)

echo "Waiting for the first line of output to create the gist..."

# Read from the pipe line-by-line
while IFS= read -r line; do
  if [ -z "$GIST_ID" ]; then
    # First line: create the gist
    echo "First output received. Creating gist..."
    echo "$line" > "$TEMP_FILE"
    # Create the gist and extract its ID
    GIST_URL=$(gh gist create "$TEMP_FILE" -d "Live App Output" -f "output.log")
    GIST_ID=$(basename "$GIST_URL")
    echo "Gist created: $GIST_URL"
  else
    # Subsequent lines: append and update the gist
    echo "$line" >> "$TEMP_FILE"
    gh gist edit "$GIST_ID" "$TEMP_FILE" > /dev/null # Suppress output
    echo "Gist updated."
  fi
done < "$PIPE"

# Wait for the application process to finish, just in case
wait $APP_PID
echo "Application has finished."

# Clean up: delete the gist and temporary files
if [ -n "$GIST_ID" ]; then
  echo "Deleting gist..."
  gh gist delete "$GIST_ID" --yes
fi

rm "$PIPE"
rm "$TEMP_FILE"

echo "Cleanup complete."
