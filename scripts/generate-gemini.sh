#!/bin/sh

for program in cat dirname echo find grep lowdown mkdir realpath; do
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
HEADER="$SOURCE/header.gmi"
FOOTER="$SOURCE/footer.gmi"
IGNORED_FILES="$SOURCE/404.md $SOURCE/5xx.md"

for md_file in $(find "$SOURCE" -type f -name "*.md"); do
  if echo "$IGNORED_FILES" | grep -qw "$md_file"; then
    continue
  fi

  relative_path="${md_file#$SOURCE/}"
  gmi_file="$DESTINATION/${relative_path%.md}.gmi"

  mkdir -p "$(dirname "$gmi_file")"

  {
    cat "$HEADER"
    lowdown -t gemini "$md_file"
    cat "$FOOTER"
  } > "$gmi_file"

  echo "Parsed: $md_file -> $gmi_file"
done
