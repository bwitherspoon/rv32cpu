all:
	vivado -mode batch -source ip.tcl -nolog -nojournal

clean:
	find . -maxdepth 1 -not -name "Makefile" -not -name "." -not -name "ip.tcl" -not -name "component.xml" -not -name "xgui" -exec rm -rf {} \;

.PHONY: all clean
