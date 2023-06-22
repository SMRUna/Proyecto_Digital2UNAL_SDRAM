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
// This is the signal module of the SDR SDRAM controller reference
// design which generates all signals required to interface with the
// SDR SDRAM.
//
// --------------------------------------------------------------------
//
// Revision History :
// --------------------------------------------------------------------
//   Ver  :| Author            :| Mod. Date :| Changes Made:
//   V0.1 :|                   :| 06/29/09  :| Pre-Release
// --------------------------------------------------------------------

`timescale 1ns / 100ps

`define sdr_COMMAND  {sdr_CSn, sdr_RASn, sdr_CASn, sdr_WEn}

module sdr_sig(
  sys_CLK,
  sys_RESET,
  sys_A,
  iState,
  cState,
  sdr_CKE,    // sdr clock enable
  sdr_CSn,    // sdr chip select
  sdr_RASn,   // sdr row address
  sdr_CASn,   // sdr column select
  sdr_WEn,    // sdr write enable
  sdr_BA,     // sdr bank address
  sdr_A       // sdr address
);

`include "sdr_par.v"

//---------------------------------------------------------------------
// inputs
//
input                     sys_CLK;
input                     sys_RESET;
input [RA_MSB:CA_LSB]     sys_A;
input [3:0]               iState;
input [3:0]               cState;

//---------------------------------------------------------------------
// outputs
//
output                    sdr_CKE;
output                    sdr_CSn;
output                    sdr_RASn;
output                    sdr_CASn;
output                    sdr_WEn;
output [SDR_BA_WIDTH-1:0] sdr_BA;
output [SDR_A_WIDTH-1:0]  sdr_A;

reg                       sdr_CKE;
reg                       sdr_CSn /*synthesis syn_keep=1*/;
reg                       sdr_RASn;
reg                       sdr_CASn;
reg                       sdr_WEn;
reg [SDR_BA_WIDTH-1:0]    sdr_BA;
reg [SDR_A_WIDTH-1:0]     sdr_A;





//---------------------------------------------------------------------
// SDR SDRAM Control Singals
//
always @(posedge sys_CLK or posedge sys_RESET)
  if (sys_RESET) begin
    `sdr_COMMAND <= #tDLY INHIBIT;
    sdr_CKE <= #tDLY 1'b0;
    sdr_BA  <= #tDLY {SDR_BA_WIDTH{1'b1}};
    sdr_A   <= #tDLY {SDR_A_WIDTH{1'b1}};
  end else
    case (iState)
      i_tRP,
      i_tRFC1,
      i_tRFC2,
      i_tMRD,
      i_NOP: begin
               `sdr_COMMAND <= #tDLY NOP;
               sdr_CKE <= #tDLY 1'b1;
               sdr_BA  <= #tDLY {SDR_BA_WIDTH{1'b1}};
               sdr_A   <= #tDLY {SDR_A_WIDTH{1'b1}};
             end
      i_PRE: begin
               `sdr_COMMAND <= #tDLY PRECHARGE;
               sdr_CKE <= #tDLY 1'b1;
               sdr_BA  <= #tDLY {SDR_BA_WIDTH{1'b1}};
               sdr_A   <= #tDLY {SDR_A_WIDTH{1'b1}};
             end
      i_AR1,
      i_AR2: begin
               `sdr_COMMAND <= #tDLY AUTO_REFRESH;
               sdr_CKE <= #tDLY 1'b1;
               sdr_BA  <= #tDLY {SDR_BA_WIDTH{1'b1}};
               sdr_A   <= #tDLY {SDR_A_WIDTH{1'b1}};
             end
      i_MRS: begin
               `sdr_COMMAND <= #tDLY LOAD_MODE_REGISTER;
               sdr_CKE <= #tDLY 1'b1;
               sdr_BA  <= #tDLY {SDR_BA_WIDTH{1'b0}};
               sdr_A   <= #tDLY {
                            2'b00,
                            MR_Write_Burst_Mode,
                            MR_Operation_Mode,
                            MR_CAS_Latency,
                            MR_Burst_Type,
                            MR_Burst_Length
                          };
             end
      i_ready:
             case (cState)
               c_idle,
               c_tRCD,
               c_tRFC,
               c_cl,
               c_rdata,
               c_wdata:  begin
                           `sdr_COMMAND <= #tDLY NOP;
                           sdr_CKE <= #tDLY 1'b1;
                           sdr_BA  <= #tDLY {SDR_BA_WIDTH{1'b1}};
                           sdr_A   <= #tDLY {SDR_A_WIDTH{1'b1}};
                         end
               c_ACTIVE: begin
                           `sdr_COMMAND <= #tDLY ACTIVE;
                           sdr_CKE <= #tDLY 1'b1;
                           sdr_BA  <= #tDLY sys_A[BA_MSB:BA_LSB];//bank
                           sdr_A   <= #tDLY sys_A[RA_MSB:RA_LSB];//row
                         end
               c_READA:  begin
                           `sdr_COMMAND <= #tDLY READ;
                           sdr_CKE <= #tDLY 1'b1;
                           sdr_BA  <= #tDLY sys_A[BA_MSB:BA_LSB];//bank
                           sdr_A   <= #tDLY {
                                        sys_A[CA_MSB],//column
                                        1'b1, //enable auto precharge
                                        sys_A[CA_MSB-1:CA_LSB],//column
                                        2'b00 //2 '0'(burst length 4)
                                      };
                           end
               c_WRITEA: begin
                           `sdr_COMMAND <= #tDLY WRITE;
                           sdr_CKE <= #tDLY 1'b1;
                           sdr_BA  <= #tDLY sys_A[BA_MSB:BA_LSB];//bank
                           sdr_A   <= #tDLY {
                                        sys_A[CA_MSB],//column
                                        1'b1, //enable auto precharge
                                        sys_A[CA_MSB-1:CA_LSB],//column
                                        2'b00 //2 '0'(burst length 4)
                                      };
                         end
               c_AR:     begin
                           `sdr_COMMAND <= #tDLY AUTO_REFRESH;
                           sdr_CKE <= #tDLY 1'b1;
                           sdr_BA  <= #tDLY {SDR_BA_WIDTH{1'b1}};
                           sdr_A   <= #tDLY {SDR_A_WIDTH{1'b1}};
                         end
               default:  begin
                           `sdr_COMMAND <= #tDLY NOP;
                           sdr_CKE <= #tDLY 1'b1;
                           sdr_BA  <= #tDLY {SDR_BA_WIDTH{1'b1}};
                           sdr_A   <= #tDLY {SDR_A_WIDTH{1'b1}};
                         end
             endcase
      default:
             begin
               `sdr_COMMAND <= #tDLY NOP;
               sdr_CKE <= #tDLY 1'b1;
               sdr_BA  <= #tDLY {SDR_BA_WIDTH{1'b1}};
               sdr_A   <= #tDLY {SDR_A_WIDTH{1'b1}};
             end
    endcase

endmodule

