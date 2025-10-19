TAG="output"
echo "Generated temporary tag: $TAG"

# Create temporary files and a named pipe for IPC.
PIPE=$(mktemp -u)
mkfifo "$PIPE"
TEMP_FILE="output"

# Cleanup function to be called on script exit (even on errors).
cleanup() {
  echo "--- Running cleanup ---"
  # Check if the release was created before trying to delete it.
  if gh release view "$TAG" > /dev/null 2>&1; then
    echo "Deleting release and tag: $TAG..."
    # The --cleanup-tag flag deletes the remote tag as well.
    gh release delete "$TAG" --cleanup-tag --yes
  else
    echo "Release was never created or already deleted. Skipping deletion."
  fi

  # Delete the local tag if it still exists.
  if git rev-parse "$TAG" > /dev/null 2>&1; then
     git tag -d "$TAG"
  fi

  git push --delete origin output

  # Remove temporary files.
  rm -f "$PIPE" "$TEMP_FILE"
  echo "Cleanup complete."
}

# Register the cleanup function to run when the script exits.
trap cleanup EXIT

# Pre-cleanup
git push --delete origin output &>/dev/null || true
# 2. EXECUTION
# Start the application in the background, redirecting its stdout to the pipe.
echo "Starting application..."
YOUR_APP="bash -c 'while true; do date;./turnshell -m -l;sleep 2; done'"

eval "$YOUR_APP" > "$PIPE" &

echo "Waiting for the first line of output to create the release..."

# Read from the pipe line-by-line.
RELEASE_CREATED=false
while IFS= read -r line; do
  # Append the new line to our temporary log file.
  echo "$line" >> "$TEMP_FILE"

  if [ "$RELEASE_CREATED" = false ]; then
    # First line: Create the tag, push it, and create the release.
    echo "First output received. Creating release..."
    git tag "$TAG"
    git push origin "$TAG"

    gh release create "$TAG" "$TEMP_FILE" \
      --title "Output" \
      --notes "Meh."

    echo "Release created successfully: $(gh release view "$TAG" --json url -q .url)"
    RELEASE_CREATED=true
  else
    # Subsequent lines: Update the release by replacing the asset.
    # The --clobber flag overwrites the existing asset file.
    gh release upload "$TAG" "$TEMP_FILE" --clobber > /dev/null
    echo "Release asset updated."
  fi
done < "$PIPE"

echo "Application has finished."

# The 'trap' will handle the final cleanup automatically.
