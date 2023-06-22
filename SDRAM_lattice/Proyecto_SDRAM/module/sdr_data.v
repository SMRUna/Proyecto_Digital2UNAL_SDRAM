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
// This is the data path module of the SDR SDRAM controller reference
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

/*
This is the data module for a synchronous DRAM controller.
*/

module sdr_data(
  sys_CLK,
  sys_RESET,
  sys_D,       // data bus
  sys_D_VALID, // data valid
  cState,
  clkCNT,
  sdr_DQ       // sdr data
);

`include "sdr_par.v"

//---------------------------------------------------------------------
// inputs
//
input        sys_CLK;
input        sys_RESET;
input [3:0]  cState;
input [3:0]  clkCNT;

//---------------------------------------------------------------------
// outputs
//
output       sys_D_VALID;

//---------------------------------------------------------------------
// bidir
//
inout [15:0] sys_D;
inout [3:0]  sdr_DQ;

reg [15:0]   regSdrDQ;
reg          enableSysD;

reg [15:0]   regSysD;
reg [3:0]    regSysDX;
reg          enableSdrDQ;

wire         stateWRITEA;

wire [3:0]   cnt0_sdrdq ;
wire [3:0]   cnt1_sdrdq ;
wire [3:0]   cnt2_sdrdq ;
wire [3:0]   cnt3_sdrdq ;






//---------------------------------------------------------------------
// sys_D_VALID Generation
//
assign #tDLY sys_D_VALID = enableSysD;

//---------------------------------------------------------------------
//  Read Cycle Data Path
//
assign #tDLY sys_D = (enableSysD) ? regSdrDQ : 16'hzzzz;

assign cnt0_sdrdq = (cState == c_rdata) && (clkCNT == 0) ? sdr_DQ : regSdrDQ[3:0];
assign cnt1_sdrdq = (cState == c_rdata) && (clkCNT == 1) ? sdr_DQ : regSdrDQ[7:4];
assign cnt2_sdrdq = (cState == c_rdata) && (clkCNT == 2) ? sdr_DQ : regSdrDQ[11:8];
assign cnt3_sdrdq = (cState == c_rdata) && (clkCNT == 3) ? sdr_DQ : regSdrDQ[15:12];

always @(posedge sys_CLK or posedge sys_RESET)
   if (sys_RESET)
      regSdrDQ <= #tDLY 16'h0000;
   else
      regSdrDQ <= #tDLY {cnt3_sdrdq,cnt2_sdrdq,cnt1_sdrdq,cnt0_sdrdq};


always @(posedge sys_CLK or posedge sys_RESET)
  if (sys_RESET)
          enableSysD <= #tDLY 0;
  else if ((cState == c_rdata) && (clkCNT == NUM_CLK_READ - 1))
          enableSysD <= #tDLY 1;
  else    enableSysD <= #tDLY 0;

//---------------------------------------------------------------------
//  Write Cycle Data Path
//
assign #tDLY sdr_DQ = (enableSdrDQ) ? regSysDX : 4'bzzzz;

always @(posedge sys_CLK or posedge sys_RESET)
  if (sys_RESET)
          regSysDX <= #tDLY 16'h0000;
  else if (cState == c_WRITEA)
          regSysDX <= #tDLY regSysD[3:0];
  else if ((cState == c_wdata) && (clkCNT == 1))
          regSysDX <= #tDLY regSysD[7:4];
  else if ((cState == c_wdata) && (clkCNT == 2))
          regSysDX <= #tDLY regSysD[11:8];
  else    regSysDX <= #tDLY regSysD[15:12];

assign #tDLY stateWRITEA = (cState == c_WRITEA) ? 1'b1 : 1'b0;

always @(posedge sys_CLK or posedge sys_RESET)
  if  (sys_RESET)
          enableSdrDQ <= #tDLY 0;
  else if (cState == c_WRITEA)
          enableSdrDQ <= #tDLY 1;
  else if ((cState == c_wdata) && (clkCNT == NUM_CLK_WRITE))
          enableSdrDQ <= #tDLY 0;

always @(posedge sys_CLK or posedge sys_RESET)
  if (sys_RESET)
          regSysD <= #tDLY 16'h0000;
  else    regSysD <= #tDLY sys_D;


endmodule

