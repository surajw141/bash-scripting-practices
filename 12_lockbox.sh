#!/bin/bash

set -e

# Check dependencies
command -v openssl >/dev/null 2>&1 || { echo "openssl is required"; exit 1; }
command -v tar >/dev/null 2>&1 || { echo "tar is required"; exit 1; }

usage() {
  echo "Usage:"
  echo "  $0 encrypt <file_or_directory>"
  echo "  $0 decrypt <encrypted_file>"
  exit 1
}

[ $# -lt 2 ] && usage

MODE="$1"
TARGET="$2"

if [ "$MODE" = "encrypt" ]; then
  if [ ! -e "$TARGET" ]; then
    echo "Error: '$TARGET' does not exist"
    exit 1
  fi

  OUTPUT="${TARGET}.enc"

  if [ -d "$TARGET" ]; then
    echo "Encrypting directory: $TARGET"
    tar -czf - "$TARGET" | \
      openssl enc -aes-256-cbc -salt -pbkdf2 -iter 200000 -out "$OUTPUT"
  else
    echo "Encrypting file: $TARGET"
    openssl enc -aes-256-cbc -salt -pbkdf2 -iter 200000 \
      -in "$TARGET" -out "$OUTPUT"
  fi

  echo "Encrypted output: $OUTPUT"

elif [ "$MODE" = "decrypt" ]; then
  if [ ! -f "$TARGET" ]; then
    echo "Error: '$TARGET' does not exist or is not a file"
    exit 1
  fi

  echo "Decrypting: $TARGET"
  openssl enc -d -aes-256-cbc -pbkdf2 -iter 200000 \
    -in "$TARGET" -out decrypted.tmp

  # Try to extract as tar (directory), otherwise treat as file
  if tar -tzf decrypted.tmp >/dev/null 2>&1; then
    tar -xzf decrypted.tmp
    rm decrypted.tmp
    echo "Decryption complete (directory restored)"
  else
    mv decrypted.tmp "${TARGET%.enc}"
    echo "Decryption complete (file restored)"
  fi

else
  usage
fi
