#!/bin/sh

for program in cat dirname echo find mkdir rm read smu;  do
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
HEADER="$SOURCE/header.html"
FOOTER="$SOURCE/footer.html"

find "$SOURCE" -type f -name "*.md" | while IFS= read -r md_file; do
  relative_path="${md_file#$SOURCE/}"
  html_file="$DESTINATION/${relative_path%.md}.html"

  mkdir -p "$(dirname "$html_file")"

  smu -n "$md_file" > "$html_file.tmp"

  {
    cat "$HEADER"
    cat "$html_file.tmp"
    cat "$FOOTER"
  } > "$html_file"

  rm "$html_file.tmp"

  echo "Parsed: $md_file -> $html_file"
done
