include config.mk

PAGES = index.html \
        blog/index.html

PAGE404 = 404.html
PAGE5XX = 5xx.html

ATOM    = atom.xml
SITEMAP = sitemap.xml

HEADER = header.html
FOOTER = footer.html

.PHONY: all clean install uninstall

all: $(PAGES) $(PAGE404) $(PAGE5XX) $(ATOM) $(SITEMAP)

clean:
	rm -f $(PAGES) $(PAGE404) $(PAGE5XX) $(ATOM) $(SITEMAP)

install: $(PAGES) $(ATOM) $(SITEMAP)
	for f in $(ATOM) $(SITEMAP) $(PAGES) favicon.ico public; do \
		mkdir -p $(DESTDIR)$(PREFIX)/$$(dirname $$f); \
		cp -rf $$f $(DESTDIR)$(PREFIX)/$$(dirname $$f); \
	done

uninstall:
	for f in $(ATOM) $(SITEMAP) $(PAGES) favicon.ico public; do \
		rm -rf $(DESTDIR)$(PREFIX)/$$f; \
	done

$(PAGES) $(PAGE404) $(PAGE5XX):
	cat $(HEADER) > $@
	$(LOWDOWN) -t html $(@:.html=.md) >> $@
	cat $(FOOTER) >> $@

$(ATOM):
	printf '<?xml version="1.0" encoding="UTF-8"?>' > $@
	printf '<feed xmlns="https://www.w3.org/2005/Atom">' >> $@
	printf '<title>$(TITLE)</title>' >> $@
	printf '<link href="$(BASEURL)/$(FEEDDIR)/" rel="self"/>' >> $@
	printf '<id>$(BASEURL)/$@</id>' >> $@

	for p in $(PAGES); do \
		if [ "$${p#$(FEEDDIR)/}" = "$$p" ]; then \
			continue; \
		elif [ "$$p" = 'index.html' ]; then \
			path=''; \
		elif [ "$$(echo $$p | tail -c 12)" = '/index.html' ]; then \
			path="$$(dirname $$p)/"; \
		else \
			path=$$p; \
		fi; \
		printf '<entry><title>' >> $@; \
		printf '<title>' >> $@; \
		title="$$path"; \
		title="$${title#$(FEEDDIR)/}"; \
		title="$${title%/}"; \
		title=$$(printf "$$title" | sed 's/-/ /g'); \
		printf "$$title" >> $@; \
		printf '</title>' >> $@; \
		printf "<link href=\"$(BASEURL)/$$path\"/>" >> $@; \
		printf '</entry>' >> $@; \
	done

	printf '</feed>' >> $@

$(SITEMAP):
	printf '<?xml version="1.0" encoding="UTF-8"?>' > $@
	printf '<urlset xmlns="https//www.sitemaps.org/schemas' >> $@
	printf '/sitemap-image/1.1">' >> $@

	for p in $(PAGES); do \
		if [ "$$p" = 'index.html' ]; then \
			path=''; \
		elif [ "$$(echo $$p | tail -c 12)" = '/index.html' ]; then \
			path="$$(dirname $$p)/"; \
		else \
			path=$$p; \
		fi; \
		printf "<url><loc>$(BASEURL)/$$path</loc></url>" >> $@; \
	done

	printf '</urlset>' >> $@
