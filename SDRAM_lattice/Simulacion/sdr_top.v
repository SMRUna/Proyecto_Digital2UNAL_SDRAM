//   ==================================================================
//   >>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
//   ------------------------------------------------------------------
//   Copyright (c) 2013 by Lattice Semiconductor Corporation
//   ALL RIGHTS RESERVED 
//   ------------------------------------------------------------------
//
//   Permission:
//
//      Lattice SG Pte. Ltd. grants permission to use this code
//      pursuant to the terms of the Lattice Reference Design License Agreement. 
//
//
//   Disclaimer:
//
//      This VHDL or Verilog source code is intended as a design reference
//      which illustrates how these types of functions can be implemented.
//      It is the user's responsibility to verify their design for
//      consistency and functionality through the use of formal
//      verification methods.  Lattice provides no warranty
//      regarding the use or functionality of this code.
//
//   --------------------------------------------------------------------
//
//                  Lattice SG Pte. Ltd.
//                  101 Thomson Road, United Square #07-02 
//                  Singapore 307591
//
//
//                  TEL: 1-800-Lattice (USA and Canada)
//                       +65-6631-2000 (Singapore)
//                       +1-503-268-8001 (other locations)
//
//                  web: http://www.latticesemi.com/
//                  email: techsupport@latticesemi.com
//
//   --------------------------------------------------------------------
//


//
// This is the top level module of the SDR SDRAM controller reference
// design.
//
// --------------------------------------------------------------------
//
// Revision History :
// --------------------------------------------------------------------
//   Ver  :| Author            :| Mod. Date :| Changes Made:
//   V0.1 :|                   :| 06/29/09  :| Pre-Release
// --------------------------------------------------------------------

`timescale 1ns / 100ps

module sdr_top(
  sys_R_Wn,      // read/write#
  sys_ADSn,      // address strobe
  sys_DLY_100US, // sdr power and clock stable for 100 us
  sys_CLK,       // sdr clock
  sys_RESET,     // reset signal
  sys_REF_REQ,   // sdr auto-refresh request
  sys_REF_ACK,   // sdr auto-refresh acknowledge
  sys_A,         // address bus
  sys_D,         // data bus
  sys_D_VALID,   // data valid
  sys_CYC_END,   // end of current cycle
  sys_INIT_DONE, // initialization completed,ready for normal operation

  sdr_DQ,        // sdr data
  sdr_A,         // sdr address
  sdr_BA,        // sdr bank address
  sdr_CKE,       // sdr clock enable
  sdr_CSn,       // sdr chip select
  sdr_RASn,      // sdr row address
  sdr_CASn,      // sdr column select
  sdr_WEn,       // sdr write enable
  sdr_DQM        // sdr write data mask
);

`include "sdr_par.v"


//---------------------------------------------------------------------
// inputs
//

input                      sys_R_Wn;
input                      sys_ADSn;
input                      sys_DLY_100US;
input                      sys_CLK;
input                      sys_RESET;
input                      sys_REF_REQ;
input [RA_MSB:CA_LSB]      sys_A;

//---------------------------------------------------------------------
// outputs
//

output                     sys_REF_ACK;
output                     sys_D_VALID;
output                     sys_CYC_END;
output                     sys_INIT_DONE;

output [SDR_A_WIDTH-1:0]   sdr_A;
output [SDR_BA_WIDTH-1:0]  sdr_BA;
output                     sdr_CKE;
output                     sdr_CSn;
output                     sdr_RASn;
output                     sdr_CASn;
output                     sdr_WEn;
output                     sdr_DQM;

//---------------------------------------------------------------------
// outputs

inout [15:0]               sys_D;
inout [3:0]                sdr_DQ;

//---------------------------------------------------------------------
// intermodule wires

wire [3:0]                 iState;    // INIT_FSM state variables
wire [3:0]                 cState;    // CMD_FSM state variables
wire [3:0]                 clkCNT;





//---------------------------------------------------------------------
// modules

assign #tDLY sdr_DQM = 0;

sdr_ctrl U1 (
  .sys_CLK(sys_CLK),
  .sys_RESET(sys_RESET),
  .sys_R_Wn(sys_R_Wn),
  .sys_ADSn(sys_ADSn),
  .sys_DLY_100US(sys_DLY_100US),
  .sys_REF_REQ(sys_REF_REQ),
  .sys_REF_ACK(sys_REF_ACK),
  .sys_CYC_END(sys_CYC_END),
  .sys_INIT_DONE(sys_INIT_DONE),
  .iState(iState),
  .cState(cState),
  .clkCNT(clkCNT)
);

sdr_sig U2 (
  .sys_CLK(sys_CLK),
  .sys_RESET(sys_RESET),
  .sys_A(sys_A),
  .iState(iState),
  .cState(cState),
  .sdr_CKE(sdr_CKE),
  .sdr_CSn(sdr_CSn),
  .sdr_RASn(sdr_RASn),
  .sdr_CASn(sdr_CASn),
  .sdr_WEn(sdr_WEn),
  .sdr_BA(sdr_BA),
  .sdr_A(sdr_A)
);

sdr_data U3 (
  .sys_CLK(sys_CLK),
  .sys_RESET(sys_RESET),
  .sys_D(sys_D),
  .sys_D_VALID(sys_D_VALID),
  .cState(cState),
  .clkCNT(clkCNT),
  .sdr_DQ(sdr_DQ)
);

endmodule


