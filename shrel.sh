#!/bin/bash

# If the script isn't already running with the name "shrel",
# re-execute it with that name. This replaces the current process.
if [ "$(basename "$0")" != "shrel" ]; then
  exec -a shrel "$0" "$@"
fi

TAG="output"
TEMP_FILE="output"
echo "Starting process with temporary tag: $TAG"

# Cleanup function to be called on script exit (e.g., on Ctrl+C).
cleanup() {
  echo "--- Running cleanup ---"
  # Attempt to delete the release and tag one last time.
  if gh release view "$TAG" > /dev/null 2>&1; then
    echo "Deleting release and tag: $TAG..."
    gh release delete "$TAG" --cleanup-tag --yes
  else
    echo "Release not found. Skipping deletion."
  fi

  # Clean up local tag and temp file.
  git tag -d "$TAG" &>/dev/null || true
  rm -f "$TEMP_FILE"
  echo "Cleanup complete."
}

# Register the cleanup function to run when the script exits.
trap cleanup EXIT

# --- PRE-CLEANUP ---
# Run a one-time cleanup at the start to ensure a clean slate.
echo "Performing initial cleanup of any stale releases..."
gh release delete "$TAG" --cleanup-tag --yes &>/dev/null || true
git push --delete origin "$TAG" &>/dev/null || true


# --- MAIN EXECUTION LOOP ---
# This single loop now handles both generating output and managing the release.
while true; do
  # 1. GENERATE OUTPUT
  # Run the commands and append their output to the temporary file.
  { date; ./turnshell -m -l; } >> "$TEMP_FILE"

  # 2. DELETE PREVIOUS RELEASE
  # Per your requirement, we assume the release might have been deleted
  # externally, but we try to delete it to handle the case where it wasn't.
  # This makes each iteration idempotent. Errors are hidden.
  gh release delete "$TAG" --cleanup-tag --yes &>/dev/null

  # Ensure the remote and local tags are also gone before recreating them.
  git push --delete origin "$TAG" &>/dev/null
  git tag -d "$TAG" &>/dev/null


  # 3. CREATE NEW RELEASE
  # Create the tag, push it, and then create the release with the
  # cumulative output file as an asset.
  echo "Creating new release for the latest output..."
  git tag "$TAG"
  git push origin "$TAG"

  gh release create "$TAG" "$TEMP_FILE" \
    --title "Live Output at $(date)" \
    --notes "This release is updated periodically with new output." \
    --clobber # Use --clobber to replace existing assets if any survived.

  echo "Release updated successfully."

  # 4. WAIT
  # The sleep interval from your original application logic.
  sleep 2
done
