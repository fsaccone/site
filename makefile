include config.mk

PAGES = index.html \
        blog/index.html

PAGE404 = 404.html
PAGE5XX = 5xx.html

FAVICON  = favicon.ico
RSS      = $(RSSDIR)/rss.xml
SITEMAP  = sitemap.xml
ICON4096 = public/icon4096.png
ICON2048 = public/icon2048.png
ICON1024 = public/icon1024.png
ICON512  = public/icon512.png
ICON256  = public/icon256.png
ICON128  = public/icon128.png
ICON64   = public/icon64.png
ICON48   = public/icon48.png
ICON32   = public/icon32.png
ICON24   = public/icon24.png
ICON16   = public/icon16.png

RSSTITLE       = Francesco Saccone
RSSDESCRIPTION = Francesco Saccone's blog.
RSSDIR         = blog

ICONSVG = public/icon.svg

HEADER = header.html
FOOTER = footer.html

.PHONY: all clean install uninstall

all: $(PAGES) $(PAGE404) $(PAGE5XX) $(FAVICON) $(RSS) $(SITEMAP) $(ICON4096) \
     $(ICON2048) $(ICON1024) $(ICON512) $(ICON128) $(ICON64) $(ICON48) \
     $(ICON32) $(ICON24) $(ICON16)

clean:
	rm -f $(PAGES) $(PAGE404) $(PAGE5XX) $(FAVICON) $(RSS) $(SITEMAP) \
	$(ICON4096) $(ICON2048) $(ICON1024) $(ICON512) $(ICON128) $(ICON64) \
	$(ICON48) $(ICON32) $(ICON24) $(ICON16)

install: $(PAGES) $(RSS) $(SITEMAP)
	for f in $(PAGES) $(FAVICON) $(RSS) $(SITEMAP) $(ICON4096) \
	         $(ICON2048) $(ICON1024) $(ICON512) $(ICON128) $(ICON64) \
	         $(ICON48) $(ICON32) $(ICON24) $(ICON16) public \
	         robots.txt; do \
		mkdir -p $(DESTDIR)$(PREFIX)/$$(dirname $$f); \
		cp -rf $$f $(DESTDIR)$(PREFIX)/$$(dirname $$f); \
	done

uninstall:
	for f in $(PAGES) $(FAVICON) $(RSS) $(SITEMAP) $(ICON4096) \
	         $(ICON2048) $(ICON1024) $(ICON512) $(ICON128) $(ICON64) \
	         $(ICON48) $(ICON32) $(ICON24) $(ICON16) public \
	         robots.txt; do \
		rm -rf $(DESTDIR)$(PREFIX)/$$f; \
	done

$(PAGES) $(PAGE404) $(PAGE5XX):
	cat $(HEADER) | tr -d '\n\t' | sed 's/  \+/ /g' > $@
	$(LOWDOWN) -t html $(@:.html=.md) >> $@
	cat $(FOOTER) | tr -d '\n\t' | sed 's/  \+/ /g' >> $@

$(FAVICON): $(ICON256) $(ICON128) $(ICON64) $(ICON48) $(ICON32) $(ICON24) \
            $(ICON16)
	$(MAGICK) $^ $@

$(ICON4096):
	$(INKSCAPE) -w 4096 -h 4096 $(ICONSVG) -o $@

$(ICON2048):
	$(INKSCAPE) -w 2048 -h 2048 $(ICONSVG) -o $@

$(ICON1024):
	$(INKSCAPE) -w 1024 -h 1024 $(ICONSVG) -o $@

$(ICON512):
	$(INKSCAPE) -w 512 -h 512 $(ICONSVG) -o $@

$(ICON256):
	$(INKSCAPE) -w 256 -h 256 $(ICONSVG) -o $@

$(ICON128):
	$(INKSCAPE) -w 128 -h 128 $(ICONSVG) -o $@

$(ICON64):
	$(INKSCAPE) -w 64 -h 64 $(ICONSVG) -o $@

$(ICON48):
	$(INKSCAPE) -w 48 -h 48 $(ICONSVG) -o $@

$(ICON32):
	$(INKSCAPE) -w 32 -h 32 $(ICONSVG) -o $@

$(ICON24):
	$(INKSCAPE) -w 24 -h 24 $(ICONSVG) -o $@

$(ICON16):
	$(INKSCAPE) -w 16 -h 16 $(ICONSVG) -o $@

$(RSS):
	printf '<?xml version="1.0" encoding="UTF-8"?>' > $@
	printf '<rss version="2.0"' >> $@
	printf ' xmlns:atom="http://www.w3.org/2005/Atom">' >> $@
	printf '<channel>' >> $@

	printf '<title>$(RSSTITLE)</title>' >> $@
	printf '<link>$(BASEURL)/$(RSSDIR)/</link>' >> $@
	printf "<description>$(RSSDESCRIPTION)</description>" >> $@
	printf "<language>en-us</language>" >> $@; \

	pages=$$(for f in $(PAGES); do echo \
	                               $$(tail -n +2 "$${f%.html}.md.time") \
	                               "$$f"; done); \
	lastbuild=$$(echo $$pages | head -n 1 | cut -d ' ' -f 1); \
	lastbuild=$$(date -u -d @"$$lastbuild" \
	             +"%a, %d %b %Y %H:%M:%S +0000"); \
	printf "<lastBuildDate>$$lastbuild</lastBuildDate>" >> $@; \
	pages=$$(echo "$$pages" | sort -n | cut -d ' ' -f 2); \
	for p in $$pages; do \
		if [ "$${p#$(RSSDIR)/}" = "$$p" ]; then \
			continue; \
		elif [ "$$p" = '$(RSSDIR)/index.html' ]; then \
			continue; \
		elif [ "$$(echo $$p | tail -c 12)" = '/index.html' ]; then \
			path="$$(dirname $$p)/"; \
		else \
			path=$$p; \
		fi; \
		printf '<entry>' >> $@; \
		printf '<title>' >> $@; \
		title=$$(head -n 1 "$${p%.html}.md" | sed 's/^# //'); \
		printf "$$title" >> $@; \
		printf '</title>' >> $@; \
		printf "<link>$(BASEURL)/$$path</link>" >> $@; \
		created=$$(head -n 1 "$${p%.html}.md.time"); \
		created=$$(date -u -d @"$$created" \
		           +"%a, %d %b %Y %H:%M:%S +0000"); \
		printf "<pubDate>$$created</pubDate>" >> $@; \
		lastmod=$$(tail -n +2 "$${p%.html}.md.time"); \
		lastmod=$$(date -u -d @"$$lastmod" \
		           +"%a, %d %b %Y %H:%M:%S +0000"); \
		printf "<lastBuildDate>$$lastmod</lastBuildDate>" >> $@; \
		content=$$(tail -n +2 "$${p%.html}.md" | $(LOWDOWN) -t html); \
		printf "<description>$$content</description>" >> $@; \
		printf '</entry>' >> $@; \
	done

	printf '</channel>' >> $@
	printf '</rss>' >> $@

$(SITEMAP):
	printf '<?xml version="1.0" encoding="UTF-8"?>' > $@
	printf '<urlset xmlns="http://www.sitemaps.org/schemas/0.9">' >> $@

	for p in $(PAGES); do \
		if [ "$$p" = 'index.html' ]; then \
			path=''; \
		elif [ "$$(echo $$p | tail -c 12)" = '/index.html' ]; then \
			path="$$(dirname $$p)/"; \
		else \
			path=$$p; \
		fi; \
		printf '<url>' >> $@; \
		printf "<loc>$(BASEURL)/$$path</loc>" >> $@; \
		lastmod=$$(tail -n +2 "$${p%.html}.md.time"); \
		lastmod=$$(date -u -d @"$$lastmod" +"%Y-%m-%dT%H:%M:%S%:z"); \
		printf "<lastmod>$$lastmod</lastmod>" >> $@; \
		printf '</url>' >> $@; \
	done

	printf '</urlset>' >> $@
