#!/bin/sh

for program in date echo find mkdir; do
  if ! command -v "$program" > /dev/null 2>&1; then
    echo "Error: Required program '$program' is not installed."
    exit 1
  fi
done

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <destination> <base-url>"
  exit 1
fi

SOURCE="$(dirname "$0")"
DESTINATION="$1"
SITEMAP_FILE="$DESTINATION/sitemap.xml"
BASE_URL="$2"

mkdir -p "$DESTINATION"

{
  echo -n '<?xml version="1.0" encoding="UTF-8"?>'
  echo -n '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap-image/1.1">'
} > "$SITEMAP_FILE"

for md_file in $(find "$SOURCE" -type f -name "*.md"); do
  relative_path="${md_file#$SOURCE/}"
  html_relative_path="${relative_path%.md}.html"

  url="$BASE_URL/$html_relative_path"
  last_modified=$(date -r "$md_file" +"%Y-%m-%d")

  {
    echo -n "<url>"
    echo -n "<loc>$url</loc>"
    echo -n "<lastmod>$last_modified</lastmod>"
    echo -n "</url>"
  } >> "$SITEMAP_FILE"
done

echo -n "</urlset>" >> "$SITEMAP_FILE"

echo "Sitemap generated: $SITEMAP_FILE"
