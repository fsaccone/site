#!/bin/sh

for program in dirname echo find grep mkdir realpath; do
  if ! command -v "$program" > /dev/null 2>&1; then
    echo "Error: Required program '$program' is not installed."
    exit 1
  fi
done

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <destination> <base-url>"
  exit 1
fi

SOURCE="$(realpath $(dirname $0)/..)"
DESTINATION="$1"
SITEMAP_FILE="$DESTINATION/sitemap.xml"
BASE_URL="$2"
IGNORED_FILES="$SOURCE/404.md $SOURCE/5xx.md"

mkdir -p "$DESTINATION"

{
  echo -n '<?xml version="1.0" encoding="UTF-8"?>'
  echo -n '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap-image/1.1">'
} > "$SITEMAP_FILE"

for md_file in $(find "$SOURCE" -type f -name "index.md"); do
  if echo "$IGNORED_FILES" | grep -qw "$md_file"; then
    continue
  fi

  md_relative_file="${md_file#$SOURCE/}"

  if [ "$md_relative_file" = "index.md" ]; then
    url_path=""
  else
    url_path="$(dirname $md_relative_file)/"
  fi

  url="$BASE_URL/$url_path"

  {
    echo -n "<url>"
    echo -n "<loc>$url</loc>"
    echo -n "</url>"
  } >> "$SITEMAP_FILE"
done

echo -n "</urlset>" >> "$SITEMAP_FILE"

echo "Sitemap generated: $SITEMAP_FILE"
