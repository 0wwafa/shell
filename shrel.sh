#!/bin/bash

# If the script isn't already running with the name "shrel",
# re-execute it with that name. This replaces the current process.
if [ "$(basename "$0")" != "shrel" ]; then
  exec -a shrel "$0" "$@"
fi

TAG="output"
echo "Generated temporary tag: $TAG"

# Create a temporary file to store output.
TEMP_FILE="output"

# Cleanup function to be called on script exit.
cleanup() {
  echo "--- Running cleanup ---"
  # Check if the release was created before trying to delete it.
  if gh release view "$TAG" > /dev/null 2>&1; then
    echo "Deleting release and tag: $TAG..."
    gh release delete "$TAG" --cleanup-tag --yes
  else
    echo "Release was never created or already deleted. Skipping deletion."
  fi

  # Delete the local tag if it still exists.
  if git rev-parse "$TAG" > /dev/null 2>&1; then
     git tag -d "$TAG"
  fi

  # Attempt to delete the remote tag, ignoring errors if it's already gone.
  git push --delete origin "$TAG" &>/dev/null || true

  # Remove the temporary file.
  rm -f "$TEMP_FILE"
  echo "Cleanup complete."
}

# Register the cleanup function to run when the script exits.
trap cleanup EXIT

# --- PRE-CLEANUP SECTION ---
# Remove any previous release or tag named "output" if it exists.
if gh release view "$TAG" > /dev/null 2>&1; then
  echo "Deleting stale release: $TAG"
  gh release delete "$TAG" --cleanup-tag --yes
fi
git push --delete origin "$TAG" &>/dev/null || true


# --- EXECUTION ---
echo "Starting application..."

# Flag to track if the release has been created.
release_created=false

# Main loop combines output generation and release management.
while true; do
  # Generate output and append to the temporary file.
  (date; ./turnshell -m -l) >> "$TEMP_FILE"

  # If this is the first run, create the release.
  if [ "$release_created" = false ]; then
    echo "First output received. Creating release..."
    git tag "$TAG"
    git push origin "$TAG"

    gh release create "$TAG" "$TEMP_FILE" \
      --title "Output" \
      --notes "Meh."

    echo "Release created successfully: $(gh release view "$TAG" --json url -q .url)"
    release_created=true
  fi

  # On every run, update the release asset with the latest file.
  # The --clobber flag replaces the existing file.
  gh release upload "$TAG" "$TEMP_FILE" --clobber > /dev/null
  echo "Release asset updated."

  sleep 2
done
