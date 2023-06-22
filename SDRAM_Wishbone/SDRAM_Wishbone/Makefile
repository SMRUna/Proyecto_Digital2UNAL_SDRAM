# Brief:	Makefile para crear proyectos con litex, riscv32 en placas ecp5
# Author: Johnny Cubides
# e-mail: jgcubidesc@gmail.com
# date: Friday 15 May 2020

TARGET=cain_test
TOP=cain_test
GATE_DIR=build/gateware
SOFT_DIR=build/software
LITEX_DIR=/home/sebastian/litex/
RTL_CPU_DIR=${LITEX_DIR}/pythondata-cpu-vexriscv/pythondata_cpu_vexriscv/verilog

# Poner la dirección del puerto serial que está usando
# o agregarlo en la línea de comandos ejemplo: make SERIAL=/dev/ttyUSB0x
SERIAL?=/dev/ttyUSB0

# Poner la dirección ip de la omega2 para poder conectarse a ella desde ssh
# o agregarlo en la línea de comandos ejemplo: make IP=x.x.x.x
IP_OMEGA?=127.0.1.1

# Poner el directorio destino de la omega2 para subir el bitstream, el lugar ideal es aquel donde tenga el script program.sh
# o agregarlo en la línea de comandos ejemplo: make IP=/root/
PATH_DEST?=/root/

NEXTPNR=nextpnr-ecp5
CC=riscv32-unknown-elf-gcc

all: ${GATE_DIR}/${TARGET}-flash.svf firmware

${GATE_DIR}/${TARGET}.bit:
	@yosys -V || (echo "\nNo se puede encontrar yosys, si está usando conda active en ésta terminal el entorno donde se instaló las herramientas, ejemplo:\n\n\
	conda activate fpga \n\n\
	para más información visite la siguiente url:"; exit 123;)
	@${NEXTPNR} -V || (echo "\nNo se puede encontrar ${NEXTPNR}, si está usando conda active en ésta terminal el entorno donde se instaló las herramientas, ejemplo:\n\n\
	conda activate fpga \n\n\
	para más información visite la siguiente url:"; exit 123;)
	./base.py

gateware: ${GATE_DIR}/${TARGET}-flash.svf

${SOFT_DIR}/common.mak: gateware

firmware: ${SOFT_DIR}/common.mak
	@${CC} -v || (echo "\nNo se puede encontrar el compilador de ${CC}, si está usando conda active en ésta terminal el entorno donde se instaló las herramientas, ejemplo:\n\n\
	conda activate fpga \n\n\
	para más información visite la siguiente url:"; exit 123;)
	$(MAKE) -C firmware/ -f Makefile all


${GATE_DIR}/${TARGET}-flash.svf : ${GATE_DIR}/${TARGET}.bit
	./bit_to_flash.py ${GATE_DIR}/$(TARGET).bit 

litex_term: firmware
	@ls ${SERIAL} || (echo "\n\nNo se encuentra ${SERIAL} conectado, verifique conexión o cambie el valor de SERIAL=${SERIAL} por un puerto serial existente\n\n"; exit 123;)
	litex_term ${SERIAL} --kernel firmware/firmware.bin


configure: ${GATE_DIR}/${TARGET}.bit
	sudo openFPGALoader --cable ft232RL --pins=RXD:RTS:TXD:CTS ${GATE_DIR}/$(TARGET).bit



gateware-clean:
	rm -f ${GATE_DIR}/*.svf ${GATE_DIR}/*.bit ${GATE_DIR}/*.config ${GATE_DIR}/*.json ${GATE_DIR}/*.ys

firmware-clean:
	make -C firmware -f Makefile clean

clean: firmware-clean gateware-clean

.PHONY: clean
