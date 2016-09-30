DIRS = src sim

all:
	for d in $(DIRS); do make -C $$d; done

test:
	for d in $(DIRS); do make -C $$d test; done

ip:
	make -C ip

clean:
	for d in $(DIRS); do make -C $$d clean; done

.PHONY: all test ip clean
