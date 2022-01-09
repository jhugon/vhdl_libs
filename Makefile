SUBDIRS = edge_detector/ simple_timer/ programmable_timer/ triggerable_timer/

all: $(SUBDIRS)
$(SUBDIRS):
	$(MAKE) -C $@

.PHONY: all $(SUBDIRS)
