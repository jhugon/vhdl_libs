SUBDIRS := $(wildcard */)
SUBDIRS := $(filter-out doc/, $(SUBDIRS))
SUBDIRS := $(filter-out vunit_old/, $(SUBDIRS))
$(info $(SUBDIRS))

all: $(SUBDIRS)
$(SUBDIRS):
	$(MAKE) -C $@

.PHONY: all $(SUBDIRS)
