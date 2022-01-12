SUBDIRS = edge_detector/ edge_maker/ programmable_timer/ simple_timer/ timer_pulser/

all: $(SUBDIRS)
$(SUBDIRS):
	$(MAKE) -C $@

.PHONY: all $(SUBDIRS)
