SUBDIRS = edges/ switches/ timers/ reset_controler/ firmware/ uart/

all: $(SUBDIRS)
$(SUBDIRS):
	$(MAKE) -C $@

.PHONY: all $(SUBDIRS)
