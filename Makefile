TARGET=cain_test
TOP=cain_test
GATE_DIR=build/gateware
SOFT_DIR=build/software
LITEX_DIR=/home/sebastian/litex
#RTL_CPU_DIR=${LITEX_DIR}/pythondata-cpu-vexriscv/pythondata_cpu_vexriscv/verilog
RTL_CPU_DIR=${LITEX_DIR}/pythondata-cpu-lm32/pythondata_cpu_lm32/verilog/rtl/



SERIAL?=/dev/ttyUSB0

NEXTPNR=nextpnr-ecp5
CC=riscv64-unknown-elf-gcc

all: gateware firmware

${GATE_DIR}/${TARGET}.bit:
	./base.py

gateware: ${GATE_DIR}/${TARGET}.bit

${SOFT_DIR}/common.mak: gateware

firmware: ${SOFT_DIR}/common.mak
	$(MAKE) -C firmware/ -f Makefile all

litex_term: firmware
	litex_term ${SERIAL} --kernel firmware/firmware.bin

configure: ${GATE_DIR}/${TARGET}.bit
	sudo openFPGALoader --cable ft232RL --pins=RXD:RTS:TXD:CTS ${GATE_DIR}/$(TARGET).bit

${TARGET}.svg:
#yosys -p "prep -top ${TOP}; write_json ${GATE_DIR}/${TARGET}_LOGIC_svg.json" ${GATE_DIR}/${TOP}.v ${RTL_CPU_DIR}/VexRiscv.v   #TOP_LEVEL_DIAGRAM
	yosys -p "prep -top ${TOP}; write_json ${GATE_DIR}/${TARGET}_LOGIC_svg.json" ${GATE_DIR}/${TOP}.v ${RTL_CPU_DIR}/lm32_top.v
	netlistsvg ${GATE_DIR}/${TARGET}.json -o ${TARGET}.svg  #--skin default.svg
#yosys -p "prep -top ${TOP} -flatten; write_json ${GATE_DIR}/${TARGET}_LOGIC_svg.json" ${GATE_DIR}/${TOP}.v ${RTL_CPU_DIR}/VexRiscv.v    #TOP_LEVEL_DIAGRAM
#netlistsvg ${GATE_DIR}/${TARGET}_LOGIC_svg.json -o ${TARGET}_LOGIC.svg  #--skin default.svg

gateware-clean:
	rm -f ${GATE_DIR}/*.svf ${GATE_DIR}/*.bit ${GATE_DIR}/*.config ${GATE_DIR}/*.json ${GATE_DIR}/*.ys *svg

firmware-clean:
	make -C firmware -f Makefile clean

clean: firmware-clean gateware-clean

.PHONY: clean

