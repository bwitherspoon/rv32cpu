DIRS := $(sort $(dir $(wildcard */)))

all:
	for d in $(DIRS); do make -C $$d; done

test:
	for d in $(DIRS); do make -C $$d test; done

clean:
	for d in $(DIRS); do make -C $$d clean; done

.PHONY: all clean
