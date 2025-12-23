#!/bin/bash

# ===== USAGE CHECK =====
if [ "$#" -lt 1 ]; then
  echo "Usage: $0 <filename_pattern> [directory]"
  echo "Example: $0 '*.log' /var/log"
  exit 1
fi

PATTERN="$1"
SEARCH_DIR="${2:-.}"   # Default to current directory

# ===== VALIDATE DIRECTORY =====
if [ ! -d "$SEARCH_DIR" ]; then
  echo "Error: Directory '$SEARCH_DIR' does not exist."
  exit 1
fi

echo "Searching for files matching '$PATTERN' in '$SEARCH_DIR'..."
echo

# ===== SEARCH =====
find "$SEARCH_DIR" -type f -iname "$PATTERN" 2>/dev/null

echo
echo "Search complete."
