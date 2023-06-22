from litex.build.generic_platform import *
from litex.build.lattice import LatticeECP5Platform
from litex.build.lattice.programmer import OpenOCDJTAGProgrammer
_io = [
    # Clk
    ("clk25", 0, Pins("P6"), IOStandard("LVCMOS33")),
    # Led
    ("user_led_n", 0, Pins("T6"), IOStandard("LVCMOS33")),
    # Button
    ("user_btn_n", 0, Pins("R7"),  IOStandard("LVCMOS33")),
    # Serial
    ("serial", 0,
        Subsignal("tx", Pins("C4")), # led (J19 DATA_LED-)
        Subsignal("rx", Pins("D4")), # btn (J19 KEY+)
        IOStandard("LVCMOS33")
    ),
    # SDR SDRAM (M12L64322A-5T)
    ("sys_CLK", 0, Pins("C8"), IOStandard("LVCMOS33")),
    ("sdram", 0,
        Subsignal("sdr_A",     Pins("A9 B9 B10 C10 D9 C9 E9 D8 E8 C7 B8")),
        Subsignal("sdr_DQ",    Pins(
            "D5 C5 E5 C6 D6 E6 D7 E7",
            "D10 C11 D11 C12 E10 C13 D13 E11",
            "A5 B4 A4 B3 A3 C3 A2 B2",
            "D14 B14 A14 B13 A13 B12 B11 A11")),
        Subsignal("sdr_WEn",  Pins("B5")),
        Subsignal("sdr_RASn", Pins("B6")),
        Subsignal("sdr_CASn", Pins("A6")),
        Subsignal("sdr_BA",    Pins("B7 A8")),
        #Subsignal("cke",  Pins("")), # 3v3
        Misc("SLEWRATE=FAST"),
        IOStandard("LVCMOS33"),
    ),

    # SDR SDRAM (M12616161A)
    #("sdram_clock", 0, Pins("C6"), IOStandard("LVCMOS33")),
    #("sdram", 0,
     #   Subsignal("a", Pins(
      #      "A9 E10 B12 D13 C12 D11 D10 E9",
       #     "D9 B7 C8")),
        #Subsignal("dq", Pins(
        #    "B13 A11 B9  C11 C9 C10 E8  B5",
         #   "B6  A6  A5  B4  C3 B3  B2  A2",
          #  "E2  E4  D3  E5  A4 D4  C4  D5",
          #  "D6  E6  D8  A8  B8 B10 B11 E11")),
        #Subsignal("we_n",  Pins("C7")),
        #Subsignal("ras_n", Pins("D7")),
        #Subsignal("cas_n", Pins("E7")),
        #Subsignal("cs_n", Pins("")), # gnd
        #Subsignal("cke",  Pins("")), # 3v3
        #Subsignal("ba",    Pins("A7")),
        #Subsignal("dm",   Pins("")), # gnd
        #IOStandard("LVCMOS33"),
        #Misc("SLEWRATE=FAST")
    #),
    '''
    # SPIFlash (W25Q32JV)
    ("spiflash", 0,
        Subsignal("cs_n", Pins("N8")),
        #Subsignal("clk",  Pins("")), driven through USRMCLK
        Subsignal("mosi", Pins("T8")),
        Subsignal("miso", Pins("T7")),
        IOStandard("LVCMOS33"),
    ),'''
    
]
_connectors = []
class Platform(LatticeECP5Platform):
    default_clk_name = "clk25"
    default_clk_period = 1e9/25e6
    def __init__(self, toolchain="trellis", **kwargs): 
        LatticeECP5Platform.__init__(self, "LFE5U-25F-6BG256C", _io, connectors=_connectors, toolchain=toolchain)
    def create_programmer(self):
        return OpenOCDJTAGProgrammer("openocd_colorlight_5a_75b.cfg")
    def do_finalize(self, fragment):
        LatticeECP5Platform.do_finalize(self, fragment)
        self.add_period_constraint(self.lookup_request("clk25", loose=True), 1e9/25e6)
