SUBDIRS = edges/ switches/ timers/ reset_controler/ firmware/ uart/ pulse_analysis/

all: $(SUBDIRS)
$(SUBDIRS):
	$(MAKE) -C $@

.PHONY: all $(SUBDIRS)
