#!/usr/bin/env python3
from migen import *
from migen.genlib.io import CRG
from litex.build.generic_platform import IOStandard, Subsignal, Pins
import cain_test as tarjeta
from litex.soc.integration.soc_core import *
from litex.soc.integration.builder import *
from ios import Led
from module import my_SDRAM
# IOs ------------------------------------------------------------------------
_serial = [
    ("serial", 0,
        Subsignal("tx", Pins("C4")),  # J1.3
        Subsignal("rx", Pins("D4")),  # J1.5
        IOStandard("LVCMOS33")
     ),
]


# BaseSoC --------------------------------------------------------------------
class BaseSoC(SoCCore):
    def __init__(self):
        platform = tarjeta.Platform()
        sys_clk_freq = int(25e6)
        platform.add_extension(_serial)
        platform.add_source("module/sdr_top.v")
        # SoC with CPU
        SoCCore.__init__(
            self, platform,
            cpu_type="lm32",
            clk_freq=25e6,
            ident="LiteX CPU tarjeta", ident_version=True,
            integrated_rom_size=0x8000,
            integrated_main_ram_size=0x4000)
        # Clock Reset Generation
        self.submodules.crg = CRG( platform.request("clk25"),
            ~platform.request("user_btn_n")
        )
        SoCCore.add_csr(self,"Data_Sdram")
        self.submodules.Data_Sdram = my_SDRAM.SDRAMverilog(platform.request("sdram",0))
        
     
# Build -----------------------------------------------------------------------
soc = BaseSoC()
builder = Builder(soc, output_dir="build", csr_csv="csr.csv", csr_svd="csr.svd")
builder.build()
