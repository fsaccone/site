#!/bin/sh

for program in cat dirname echo find grep lowdown mkdir realpath;  do
  if ! command -v "$program" > /dev/null 2>&1; then
    echo "Error: Required program '$program' is not installed."
    exit 1
  fi
done

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <destination>"
  exit 1
fi

SOURCE="$(realpath $(dirname $0)/..)"
DESTINATION="$1"
HEADER="$SOURCE/header.html"
FOOTER="$SOURCE/footer.html"
IGNORED_FILES="$SOURCE/404.md $SOURCE/5xx.md"

for md_file in $(find "$SOURCE" -type f -name "*.md"); do
  if echo "$IGNORED_FILES" | grep -qw "$md_file"; then
    continue
  fi

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
