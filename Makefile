SUBDIRS = edge_detector/ edge_maker/ programmable_timer/ simple_timer/ timer_pulser/ pulse_prescaler/ switch_debouncer/

all: $(SUBDIRS)
$(SUBDIRS):
	$(MAKE) -C $@

.PHONY: all $(SUBDIRS)
