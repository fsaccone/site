include config.mk

HEADER = header.html
FOOTER = footer.html
PAGES  = 404.html \
         5xx.html \
         index.html \
         blog/index.html

.PHONY: all clean

all: $(PAGES)

clean:
	rm -f $(PAGES)

$(PAGES):
	mkdir -p $$(dirname $@)
	cat $(HEADER) > $@
	$(LOWDOWN) -t html $(@:.html=.md) >> $@
	cat $(FOOTER) >> $@
