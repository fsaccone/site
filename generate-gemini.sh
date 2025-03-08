#!/bin/sh

for program in cat dirname echo find lowdown mkdir rm read;  do
  if ! command -v "$program" > /dev/null 2>&1; then
    echo "Error: Required program '$program' is not installed."
    exit 1
  fi
done

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <destination>"
  exit 1
fi

SOURCE="$(dirname "$0")"
DESTINATION="$1"

find "$SOURCE" -type f -name "*.md" | while IFS= read -r md_file; do
  relative_path="${md_file#$SOURCE/}"
  gemini_file="$DESTINATION/${relative_path%.md}.gmi"

  mkdir -p "$(dirname "$gemini_file")"

  lowdown -t gemini "$md_file" > "$gemini_file"

  echo "Parsed: $md_file -> $gemini_file"
done
