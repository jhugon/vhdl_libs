SUBDIRS = seven_seg_decoder/ seven_seg_digit_mux/ seven_seg_num_display/

all: $(SUBDIRS)
$(SUBDIRS):
	$(MAKE) -C $@

.PHONY: all $(SUBDIRS)
