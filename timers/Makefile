SUBDIRS =  programmable_timer/ simple_timer/ timer_pulser/ pulse_prescaler/ triggerable_timer/

all: $(SUBDIRS)
$(SUBDIRS):
	$(MAKE) -C $@

.PHONY: all $(SUBDIRS)
