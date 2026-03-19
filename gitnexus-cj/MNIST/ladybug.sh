#!/usr/bin/env bash

set -e

# Default values
DB_DIR=""
DB_FILE="lbug"

# Parse CLI arguments
while getopts "d:f:" opt; do
  case $opt in
    d)
      DB_DIR="$OPTARG"
      ;;
    f)
      DB_FILE="$OPTARG"
      ;;
    *)
      echo "Usage: $0 [-d database_dir] [-f database_file]"
      exit 1
      ;;
  esac
done

# Resolve DB_DIR if not provided
if [ -z "$DB_DIR" ]; then
  CURRENT_DIR_NAME="$(basename "$PWD")"

  if [ -d "$PWD/.gitnexus" ]; then
    DB_DIR="$PWD/.gitnexus"
  elif [ "$CURRENT_DIR_NAME" = ".gitnexus" ]; then
    DB_DIR="$PWD"
  else
    echo "❌ Could not determine database directory."
    echo "Provide one with -d <path>"
    exit 1
  fi
fi

# Expand to absolute path
DB_DIR="$(cd "$DB_DIR" && pwd)"

echo "📂 Using database directory: $DB_DIR"
echo "🗄️  Using database file: $DB_FILE"

# Run Docker container
docker run -p 8000:8000 \
  -v "$DB_DIR:/database" \
  -e LBUG_FILE="$DB_FILE" \
  --rm ghcr.io/ladybugdb/explorer:latest
