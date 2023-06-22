from migen import *
from migen.genlib.cdc import MultiReg
from litex.soc.interconnect.csr import *
from litex.soc.interconnect.csr_eventmanager import *

class SDRAMverilog(Module,AutoCSR):
   def __init__(self, data):
   # Interfaz
      self.clk_i    = ClockSignal()
      self.rst_i    = ResetSignal()
      #self.uart_txd = data.uart_txd
      #self.uart_rxd = data.uart_rxd
      self.sdram_data_io = data.sdram_data_io

   # registros solo lectura      
      self.data_o  = CSRStatus(32)
      self.stall_o = CSRStatus()
      self.ack_o = CSRStatus()
      self.sdram_clk_o  = CSRStatus()
      self.sdram_cke_o= CSRStatus()
      self.sdram_cs_o = CSRStatus()
      self.sdram_ras_o  = CSRStatus()
      self.sdram_cas_o  = CSRStatus()
      self.sdram_we_o  = CSRStatus()
      self.sdram_dqm_o = CSRStatus(2)
      self.sdram_addr_o = CSRStatus(13)
      self.sdram_ba_o  = CSRStatus(2)

   # Registros solo escritura       
      self.stb_i   = CSRStorage()
      self.we_i   = CSRStorage()
      self.sel_i   = CSRStorage(4)
      self.cyc_i   = CSRStorage()
      self.addr_i   = CSRStorage(32)
      self.data_i  = CSRStorage(32)
    
      #self.sys_D = CSRStorage(16)
      #self.sdr_DQ = CSRStorage(4)
   # Instanciación del módulo verilog     
      self.specials +=Instance("sdram", 
	         i_clk_i      = self.clk_i,
           	 i_rst_i    = self.rst_i,
	         io_sdram_data_io = self.sdram_data_io,
             o_data_o   = self.data_o.status,
	         o_stall_o = self.stall_o.status,
	         o_ack_o = self.ack_o.status,
	         o_sdram_clk_o  = self.sdram_clk_o.status,
	         o_sdram_cke_o = self.sdram_cke_o.status,
	         o_sdram_cs_o = self.sdram_cs_o.status,
	         o_sdram_ras_o = self.sdram_ras_o.status,
	         o_sdram_cas_o = self.sdram_cas_o.status,
	         o_sdram_we_o = self.sdram_we_o.status,
	         o_sdram_dqm_o = self.sdram_dqm_o.status,
	         o_sdram_addr_o = self.sdram_addr_o.status,
	         o_sdram_ba_o = self.sdram_ba_o.status,
             i_stb_i = self.stb_i.storage,
	         i_we_i = self.we_i.storage,
	         i_sel_i = self.sel_i.storage,
	         i_cyc_i = self.cyc_i.storage,
	         i_addr_i = self.addr_i.storage,
	         i_data_i = self.data_i.storage,
	   )	   
      self.submodules.ev = EventManager()
      self.ev.ok = EventSourceProcess()
      self.ev.finalize()
