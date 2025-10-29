include config.mk

PAGES = index.html \
        blog/index.html

PAGE404 = 404.html
PAGE5XX = 5xx.html

RSSTITLE       = Francesco Saccone
RSSDESCRIPTION = Francesco Saccone's blog.
RSSDIR         = blog
RSS            = $(RSSDIR)/rss.xml
SITEMAP        = sitemap.xml

HEADER = header.html
FOOTER = footer.html

.PHONY: all clean install uninstall

all: $(PAGES) $(PAGE404) $(PAGE5XX) $(RSS) $(SITEMAP)

clean:
	rm -f $(PAGES) $(PAGE404) $(PAGE5XX) $(RSS) $(SITEMAP)

install: $(PAGES) $(RSS) $(SITEMAP)
	for f in $(RSS) $(SITEMAP) $(PAGES) favicon.ico public; do \
		mkdir -p $(DESTDIR)$(PREFIX)/$$(dirname $$f); \
		cp -rf $$f $(DESTDIR)$(PREFIX)/$$(dirname $$f); \
	done

uninstall:
	for f in $(RSS) $(SITEMAP) $(PAGES) favicon.ico public; do \
		rm -rf $(DESTDIR)$(PREFIX)/$$f; \
	done

$(PAGES) $(PAGE404) $(PAGE5XX):
	cat $(HEADER) > $@
	$(LOWDOWN) -t html $(@:.html=.md) >> $@
	cat $(FOOTER) >> $@

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
