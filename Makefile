SIM ?= icarus
TOPLEVEL_LANG ?= verilog

VERILOG_SOURCES += data_parity_filter.v
VERILOG_SOURCES += data_parity_filter_wrapper.v


parity_tester:
	rm -rf sim_build
	$(MAKE) sim MODULE=test_filter_main TOPLEVEL=data_parity_filter_wrapper

include $(shell cocotb-config --makefiles)/Makefile.sim