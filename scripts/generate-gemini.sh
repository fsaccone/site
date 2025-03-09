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

SOURCE="$(dirname "$0" | dirname)"
DESTINATION="$1"
HEADER="$SOURCE/header.gmi"
FOOTER="$SOURCE/footer.gmi"

for md_file in $(find "$SOURCE" -type f -name "*.md"); do
  relative_path="${md_file#$SOURCE/}"
  gemini_file="$DESTINATION/${relative_path%.md}.gmi"

  mkdir -p "$(dirname "$gemini_file")"

  {
    cat "$HEADER"
    lowdown -t gemini "$md_file"
    cat "$FOOTER"
  } > "$gemini_file"

  echo "Parsed: $md_file -> $gemini_file"
done
