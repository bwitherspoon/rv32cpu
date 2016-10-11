all:
	vivado -mode batch -source core.tcl -nolog -nojournal

clean:
	find . -maxdepth 1 -not -name "Makefile" -not -name "." -not -name "core.tcl" -exec rm -rf {} \;

.PHONY: all clean
