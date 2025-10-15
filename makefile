include config.mk

HEADER  = header.html
FOOTER  = footer.html
PUBLIC  = public/
FAVICON = favicon.ico

PAGES = 404.html \
        5xx.html \
        index.html \
        blog/index.html

.PHONY: all clean install uninstall

all: $(PAGES)

clean:
	rm -f $(PAGES)

install: all
	mkdir -p $(DESTDIR)$(PREFIX)
	cp -rf $(PUBLIC) $(FAVICON) $(DESTDIR)$(PREFIX)
	for p in $(PAGES); do mkdir -p $(DESTDIR)$(PREFIX)/$$(dirname $$p) \
	                   && cp -f $$p $(DESTDIR)$(PREFIX)/$$p; done

uninstall:
	rm -rf $(DESTDIR)$(PREFIX)/$(PUBLIC) $(DESTDIR)$(PREFIX)/$(FAVICON)
	for p in $(PAGES); do rm -f $(DESTDIR)$(PREFIX)/$$p; done

$(PAGES):
	mkdir -p $$(dirname $@)
	cat $(HEADER) > $@
	$(LOWDOWN) -t html $(@:.html=.md) >> $@
	cat $(FOOTER) >> $@
