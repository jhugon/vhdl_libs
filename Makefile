SUBDIRS = edges/ switches/ timers/ reset_controler/ firmware/

all: $(SUBDIRS)
$(SUBDIRS):
	$(MAKE) -C $@

.PHONY: all $(SUBDIRS)
