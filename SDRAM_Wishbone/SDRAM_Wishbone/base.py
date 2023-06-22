#!/usr/bin/env python3
import os
import argparse
import sys
import subprocess
from migen import *
from litex.build.generic_platform import IOStandard, Subsignal, Pins
from migen.genlib.resetsync import AsyncResetSynchronizer
from litex.build.io import DDROutput
import cain_test
from litex.build.lattice.trellis import trellis_args, trellis_argdict
from litex.soc.cores.clock import *
from litex.soc.integration.soc_core import *
from litex.soc.integration.builder import *
from litedram.modules import M12L64322A
from litedram.phy import GENSDRPHY, HalfRateGENSDRPHY
from ios import Led
kB = 1024
mB = 1024*kB
# IOs -----------------------------------------------------------------------------------------
_leds = [
    ("user_led", 0, Pins("T6"), IOStandard("LVCMOS33")),  # LED en la placa
    ("user_led", 1, Pins("F3"), IOStandard("LVCMOS33")),  # LED externo
]
# BaseSoC -----------------------------------------------------------------------------------------
class _CRG(Module):
    def __init__(self, platform, sys_clk_freq, use_internal_osc=False, with_usb_pll=False, with_rst=True, sdram_rate="1:1"):
        self.rst = Signal()
        self.clock_domains.cd_sys      = ClockDomain()    
        self.clock_domains.cd_sys2x    = ClockDomain()
        self.clock_domains.cd_sys2x_ps = ClockDomain(reset_less=True)    
        clk = platform.request("clk25")
        clk_freq = 25e6
        rst_n = platform.request("user_btn_n", 0)
        # PLL
        self.submodules.pll = pll = ECP5PLL()
        self.comb += pll.reset.eq(~rst_n | self.rst)
        pll.register_clkin(clk, clk_freq)
        pll.create_clkout(self.cd_sys,    sys_clk_freq)
        pll.create_clkout(self.cd_sys2x,    2*sys_clk_freq)
        pll.create_clkout(self.cd_sys2x_ps, 2*sys_clk_freq, phase=180) # Idealy 90° but needs to be increased.
        # SDRAM clock
        sdram_clk = ClockSignal("sys2x_ps")
        self.specials += DDROutput(1, 0, platform.request("sdram_clock"), sdram_clk)

class BaseSoC(SoCCore):
    def __init__(self):
        SoCCore.mem_map = {
            "rom":          0x00000000,
            "sram":         0x10000000,
            "main_ram":     0x40000000,
            "csr":          0x82000000,
        }
        platform = cain_test.Platform()
        sys_clk_freq = int(90e6)
        platform.add_extension(_leds)
        # SoC with CPU
        SoCCore.__init__(self, platform,
            cpu_type                 = "vexriscv",
            #cpu_variant              = "linux",
            clk_freq                 = sys_clk_freq,
            ident                    = "LiteX RISC-V SoC on 5A-75B",
            ident_version            = True,
            max_sdram_size           = 0x800000, # Limit mapped SDRAM to 2MB.
            integrated_rom_size      = 0x8000)
        self.submodules.crg = _CRG(
            platform         = platform,
            sys_clk_freq     = sys_clk_freq,
            use_internal_osc = False,
            with_usb_pll     = False,
            with_rst         = False,
            sdram_rate       = "1:1")
        self.submodules.sdrphy = GENSDRPHY(platform.request("sdram"))
        self.add_sdram("sdram",
            phy                     = self.sdrphy,
            module                  = M12L64322A(sys_clk_freq, "1:2"),
            origin                  = self.mem_map["main_ram"],
            size                    = 8*mB,
            l2_cache_size           = 0x8000,
            l2_cache_min_data_width = 128,
            l2_cache_reverse        = True
        )
        user_leds = Cat(*[platform.request("user_led", i) for i in range(1)])
        self.submodules.leds = Led(user_leds)
        self.add_csr("leds")
# Build --------------------------------------------------------------------------------------------
soc = BaseSoC()
builder = Builder(soc, output_dir="build", csr_csv="csr.csv", csr_svd="csr.svd")
builder.build()
