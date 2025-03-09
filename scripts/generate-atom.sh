#!/bin/sh

for program in date dirname echo find mkdir sed; do
  if ! command -v "$program" > /dev/null 2>&1; then
    echo "Error: Required program '$program' is not installed."
    exit 1
  fi
done

if [ "$#" -ne 3 ]; then
  echo "Usage: $0 <destination> <title> <base-url>"
  exit 1
fi

SOURCE="$(dirname $0 | dirname)"
BLOG_SOURCE="$SOURCE/blog"
DESTINATION="$1"
ATOM_FILE="$DESTINATION/atom.xml"
TITLE="$2"
BASE_URL="$3"

mkdir -p "$DESTINATION"

BLOG_LAST_MODIFIED=$(date -ur "$BLOG_SOURCE" +"%Y-%m-%dT%H:%M:%SZ")

{
  echo -n "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
  echo -n "<feed xmlns=\"http://www.w3.org/2005/Atom\">"
  echo -n "<title>${TITLE}</title>"
  echo -n "<link href=\"${BASE_URL}\" rel=\"self\"/>"
  echo -n "<updated>$BLOG_LAST_MODIFIED</updated>"
  echo -n "<id>$BASE_URL/atom.xml</id>"
} > "$ATOM_FILE"

for md_file
in $(find "$BLOG_SOURCE" -mindepth 2 -maxdepth 2 -type f -name "index.md"); do
  md_relative_file="${md_file#$BLOG_SOURCE/}"
  
  # Since md_relative_file will be of "some-name/index.md", we can just call
  # its dirname as "title id" or "unformatted title".
  entry_title_id=$(dirname "$md_relative_file")

  url="$BASE_URL/blog/$entry_title_id"

  # First capitalise the first letter, then replace hyphens with spaces.
  entry_title=$(echo "${entry_title_id^}" | sed -e 's/-/ /g')
  
  last_modified=$(date -ur "$md_file" +"%Y-%m-%dT%H:%M:%SZ")

  {
    echo -n "<entry>"
    echo -n "<title>$entry_title</title>"
    echo -n "<link href=\"$url\"/>"
    echo -n "<updated>$last_modified</updated>"
    echo -n "</entry>"
  } >> "$ATOM_FILE"
done

echo -n "</feed>" >> "$ATOM_FILE"

echo "Atom generated: $ATOM_FILE"
