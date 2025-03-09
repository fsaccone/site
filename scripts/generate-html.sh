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

SOURCE="$(dirname $0 | dirname)"
DESTINATION="$1"
HEADER="$SOURCE/header.html"
FOOTER="$SOURCE/footer.html"

for md_file in $(find "$SOURCE" -type f -name "*.md"); do
  relative_path="${md_file#$SOURCE/}"
  html_file="$DESTINATION/${relative_path%.md}.html"

  mkdir -p "$(dirname "$html_file")"

  {
    cat "$HEADER"
    lowdown -t html "$md_file"
    cat "$FOOTER"
  } > "$html_file"

  echo "Parsed: $md_file -> $html_file"
done
