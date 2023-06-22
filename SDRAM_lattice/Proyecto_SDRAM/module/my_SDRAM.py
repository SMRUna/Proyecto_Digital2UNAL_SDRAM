from migen import *
from migen.genlib.cdc import MultiReg
from litex.soc.interconnect.csr import *
from litex.soc.interconnect.csr_eventmanager import *

class SDRAMverilog(Module,AutoCSR):
   def __init__(self, data):
   # Interfaz
      self.sys_CLK     = ClockSignal()
      self.sys_RESET     = ResetSignal()
      #self.uart_txd = data.uart_txd
      #self.uart_rxd = data.uart_rxd
      self.sys_D = data.sys_D 
      self.sdr_DQ = data.sdr_DQ
   # registros solo lectura      
      self.sys_REF_ACK  = CSRStatus()
      self.sys_D_VALID = CSRStatus()
      self.sys_CYC_END = CSRStatus()
      self.sys_INIT_DONE  = CSRStatus()
      self.sdr_A = CSRStatus(11)
      self.sdr_BA = CSRStatus(2)
      self.sdr_CKE  = CSRStatus()
      self.sdr_CSn  = CSRStatus()
      self.sdr_RASn  = CSRStatus()
      self.sdr_CASn  = CSRStatus()
      self.sdr_WEn  = CSRStatus()
      self.sdr_DQM  = CSRStatus()
      #self.sys_D = CSRStatus(16)
      #self.sdr_DQ = CSRStatus(4)
   # Registros solo escritura       
      self.sys_R_Wn   = CSRStorage()
      self.sys_ADSn  = CSRStorage()
      self.sys_DLY_100US  = CSRStorage()
      self.sys_REF_REQ = CSRStorage()
      self.sys_A  = CSRStorage(23)
      #self.sys_D = CSRStorage(16)
      #self.sdr_DQ = CSRStorage(4)
   # Instanciación del módulo verilog     
      self.specials +=Instance("sdr_top", 
	         i_sys_CLK       = self.sys_CLK,
          	i_sys_RESET     = self.sys_RESET,
	        io_sys_D = self.sys_D,
                io_sdr_DQ= self.sdr_DQ,
            o_sys_REF_ACK   = self.sys_REF_ACK.status,
	         o_sys_D_VALID = self.sys_D_VALID.status,
	         o_sys_CYC_END = self.sys_CYC_END.status,
	         o_sys_INIT_DONE = self.sys_INIT_DONE.status,
	         o_sdr_A = self.sdr_A.status,
	         o_sdr_BA = self.sdr_BA.status,
	         o_sdr_CKE = self.sdr_CKE.status,
	         o_sdr_CSn = self.sdr_CSn.status,
	         o_sdr_RASn = self.sdr_RASn.status,
	         o_sdr_CASn = self.sdr_CASn.status,
	         o_sdr_WEn = self.sdr_WEn.status,
	         o_sdr_DQM = self.sdr_DQM.status,
            i_sys_R_Wn   = self.sys_R_Wn.storage,
	         i_sys_ADSn  = self.sys_ADSn.storage,
	         i_sys_DLY_100US = self.sys_DLY_100US.storage,
	         i_sys_REF_REQ = self.sys_REF_REQ.storage,
	   )	   
      self.submodules.ev = EventManager()
      self.ev.ok = EventSourceProcess()
      self.ev.finalize()
