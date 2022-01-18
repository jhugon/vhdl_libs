SUBDIRS = edges/ switches/ timers/ reset_controler/ firmware/ pulse_analysis/

all: $(SUBDIRS)
$(SUBDIRS):
	$(MAKE) -C $@

.PHONY: all $(SUBDIRS)
