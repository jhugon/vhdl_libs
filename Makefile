SUBDIRS = edges/ switches/ timers/ reset_controler/ firmware/ uart/ seven_seg_display/

all: $(SUBDIRS)
$(SUBDIRS):
	$(MAKE) -C $@

.PHONY: all $(SUBDIRS)
