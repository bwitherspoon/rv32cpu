DIRS = src sim

all:
	for d in $(DIRS); do make -C $$d; done

clean:
	for d in $(DIRS); do make -C $$d clean; done

.PHONY: all clean
