TARGET          = sdr

IVERILOG        = iverilog


SRC             = \
     $(TARGET)_top.v sdr_ctrl.v sdr_data.v sdr_sig.v 

SIM_SRC = $(TARGET)_tb.v          \


clean:
	rm -rf *~ */*~ a.out *.log *.key *.edf *.json *.config *.vvp  *.svg *rpt
	rm -rf *.bit

cleanall: clean
	rm -rf build simulation/work simulation/transcript  simulation/vsim.wlf simulation/$(DESIGN)_tb.vvp simulation/*

#
#

iversim: 
	$(IVERILOG) -gno-io-range-error -o $(TARGET)_tb.vvp $(VINCDIR) $(SRC) $(SIM_SRC) -s $(TARGET)_tb
	vvp $(TARGET)_tb.vvp; 
	gtkwave $(TARGET)_tb.vcd&


