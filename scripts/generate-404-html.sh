#!/bin/sh

for program in cat dirname echo lowdown realpath; do
  if ! command -v "$program" > /dev/null 2>&1; then
    echo "Error: Required program '$program' is not installed."
    exit 1
  fi
done

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <destination_file_with_html_extension>"
  exit 1
fi

SOURCE="$(realpath $(dirname $0)/..)"
DESTINATION_FILE="$1"
HEADER="$SOURCE/header.html"
FOOTER="$SOURCE/footer.html"

{
  cat "$HEADER"
  lowdown -t html "$SOURCE/404.md"
  cat "$FOOTER"
} > "$DESTINATION_FILE"

echo "404 error page generated: $DESTINATION_FILE"
