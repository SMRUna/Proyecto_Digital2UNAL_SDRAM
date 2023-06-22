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
// This is the test bench module of the SDR SDRAM controller reference
// design.  It is highly recommanded to download simulation modules
// from the SDRAM venders when you are working on the modification of
// the SDR SDRAM controller reference design.
//
// --------------------------------------------------------------------
//
// Revision History :
// --------------------------------------------------------------------
//   Ver  :| Author            :| Mod. Date :| Changes Made:
//   V0.1 :|                   :| 06/29/09  :| Pre-Release
// --------------------------------------------------------------------

`timescale 1ns / 1ps

module sdr_tb;

wire sys_R_Wn;      // read/write#
wire sys_ADSn;      // address strobe
wire sys_DLY_100US; // sdr power and clock stable for 100 us
wire sys_CLK;       // sdr clock
wire sys_RESET;     // reset signal
wire sys_REF_REQ;   // sdr auto-refresh request
wire sys_REF_ACK;   // sdr auto-refresh acknowledge
wire [23:1] sys_A;  // address bus
wire [15:0] sys_D;  // data bus
wire sys_D_VALID;   // data valid
wire sys_CYC_END;   // end of current cycle
wire sys_INIT_DONE; // initialization completed, ready for normal operation

wire [3:0] sdr_DQ;  // sdr data
wire [11:0] sdr_A;  // sdr address
wire [1:0] sdr_BA;  // sdr bank address
wire sdr_CKE;       // sdr clock enable
wire sdr_CSn;       // sdr chip select
wire sdr_RASn;      // sdr row address
wire sdr_CASn;      // sdr column select
wire sdr_WEn;       // sdr write enable
wire sdr_DQM;       // sdr write data mask

//---------------------------------------------------------------------
// modules

sdr_top UUT(
  .sys_R_Wn(sys_R_Wn),      // read/write#
  .sys_ADSn(sys_ADSn),      // address strobe
  .sys_DLY_100US(sys_DLY_100US), // sdr power and clock stable for 100 us
  .sys_CLK(sys_CLK),       // sdr clock
  .sys_RESET(sys_RESET),     // reset signal
  .sys_REF_REQ(sys_REF_REQ),   // sdr auto-refresh request
  .sys_REF_ACK(sys_REF_ACK),   // sdr auto-refresh acknowledge
  .sys_A(sys_A),         // address bus
  .sys_D(sys_D),         // data bus
  .sys_D_VALID(sys_D_VALID),   // data valid
  .sys_CYC_END(sys_CYC_END),   // end of current cycle
  .sys_INIT_DONE(sys_INIT_DONE), // initialization completed, ready for normal operation

  .sdr_DQ(sdr_DQ),        // sdr data
  .sdr_A(sdr_A),         // sdr address
  .sdr_BA(sdr_BA),        // sdr bank address
  .sdr_CKE(sdr_CKE),       // sdr clock enable
  .sdr_CSn(sdr_CSn),       // sdr chip select
  .sdr_RASn(sdr_RASn),      // sdr row address
  .sdr_CASn(sdr_CASn),      // sdr column select
  .sdr_WEn(sdr_WEn),       // sdr write enable
  .sdr_DQM(sdr_DQM)        // sdr write data mask
);

system STIMULUS(
  .sys_CLK(sys_CLK),
  .sys_RESET(sys_RESET),
  .sys_A(sys_A),
  .sys_ADSn(sys_ADSn),
  .sys_R_Wn(sys_R_Wn),
  .sys_D(sys_D),
  .sys_DLY_100US(sys_DLY_100US),
  .sys_REF_REQ(sys_REF_REQ),
  .sys_CYC_END(sys_CYC_END),
  .sys_INIT_DONE(sys_INIT_DONE)
);

// Module "mt48lc32m4a2" can be downloaded from Micro's web site.

//mt48lc32m4a2 SDR_SDRAM(
sdr SDR_SDRAM(
  sdr_DQ,
  sdr_A,
  sdr_BA,
  sys_CLK,
  sdr_CKE,
  sdr_CSn,
  sdr_RASn,
  sdr_CASn,
  sdr_WEn,
  sdr_DQM
);

endmodule

module sdr (
  sdr_DQ,        // sdr data
  sdr_A,         // sdr address
  sdr_BA,        // sdr bank address
  sdr_CK,        // sdr clock
  sdr_CKE,       // sdr clock enable
  sdr_CSn,       // sdr chip select
  sdr_RASn,      // sdr row address
  sdr_CASn,      // sdr column select
  sdr_WEn,       // sdr write enable
  sdr_DQM        // sdr write data mask
);

//---------------------------------------------------------------------
// parameters of 8 Meg x 4 x 4 banks
//
parameter Num_Meg    =  8; //  8 Mb
parameter Data_Width =  4; //  4 bits
parameter Num_Bank   =  4; //  4 banks

parameter tAC = 5.4;
parameter tOH = 2.7;

parameter SDR_A_WIDTH  =  12; // 12 bits
parameter SDR_BA_WIDTH =  2;  // 2 bits (4 banks)

parameter MEG = 21'h100000;
parameter MEM_SIZE = Num_Meg * MEG * Num_Bank;
parameter ROW_WIDTH = 12;
parameter COL_WIDTH = (Data_Width ==  4) ? 11 :
                      (Data_Width ==  8) ? 10 :
                      (Data_Width == 16) ?  9 : 0;

//---------------------------------------------------------------------
// ports
//
input [SDR_A_WIDTH-1:0]  sdr_A;
input [SDR_BA_WIDTH-1:0] sdr_BA;
input                    sdr_CK;
input                    sdr_CKE;
input                    sdr_CSn;
input                    sdr_RASn;
input                    sdr_CASn;
input                    sdr_WEn;
input                    sdr_DQM;
inout [Data_Width-1:0]   sdr_DQ;

//---------------------------------------------------------------------
// registers
//
reg [Data_Width-1:0] Memory [0:MEM_SIZE-1];
reg [Data_Width-1:0] Memory_read [0:MEM_SIZE-1];

reg [2:0]              casLatency;
reg [2:0]              burstLength;

reg [SDR_BA_WIDTH-1:0] bank;
reg [ROW_WIDTH-1:0]    row;
reg [COL_WIDTH-1:0]    column;

reg [3:0] counter;

reg [Data_Width-1:0]   dataOut;
reg enableSdrDQ;

reg write;
reg latency;
reg read;
reg [15:0]read_count;
reg [15:0]write_count;

//---------------------------------------------------------------------
// code
//
initial begin
  casLatency = 0;
  burstLength = 0;
  bank = 0;
  row = 0;
  column = 0;
  counter = 0;
  dataOut = 0;
  enableSdrDQ = 0;
  write = 0;
  latency = 0;
  read = 0;
  read_count = 0;
  write_count = 0;
end

assign sdr_DQ =
         (Data_Width ==  4) ? (enableSdrDQ ? dataOut :  4'hz) :
         (Data_Width ==  8) ? (enableSdrDQ ? dataOut :  8'hzz) :
         (Data_Width == 16) ? (enableSdrDQ ? dataOut : 16'hzzzz) : 0;

always @(posedge sdr_CK)
  case ({sdr_CSn,sdr_RASn,sdr_CASn,sdr_WEn})
    4'b0000: begin
               $display($time,"ns : Load Mode Register 0x%h",sdr_A);
               casLatency = sdr_A[6:4];
               burstLength = (sdr_A[2:0] == 3'b000) ? 1 :
                             (sdr_A[2:0] == 3'b001) ? 2 :
                             (sdr_A[2:0] == 3'b010) ? 4 :
                             (sdr_A[2:0] == 3'b011) ? 8 : 0;
               $display($time,
                     "ns : mode: CAS Latency=0x%h, Burst Length=0x%h",
                     casLatency, burstLength);
             end
    4'b0001: $display($time,"ns : Auto Refresh Command");
    4'b0010: $display($time,"ns : Precharge Command");
    4'b0011: begin
               $display($time,"ns : Activate Command");
               row = sdr_A;
             end
    4'b0100: begin
               $display($time,"ns : Write Command");
               column = (Data_Width ==  4) ? {sdr_A[11],sdr_A[9:0]} :
                        (Data_Width ==  8) ? {sdr_A[9:0]} :
                        (Data_Width == 16) ? {sdr_A[8:0]} : 0;
               bank = sdr_BA;
               write = 1;
               counter = burstLength;
               Memory[{row,column,bank}] = sdr_DQ;
               $display($time,
                     "ns :write: Bank=0x%h, Row=0x%h, Column=0x%h, Data=0x%h",
                     bank, row, column, sdr_DQ);
				write_count = write_count +1;
             end
    4'b0101: begin
               $display($time,"ns : Read Command");
               column = (Data_Width ==  4) ? {sdr_A[11],sdr_A[9:0]} :
                        (Data_Width ==  8) ? {sdr_A[9:0]} :
                        (Data_Width == 16) ? {sdr_A[8:0]} : 0;
               bank = sdr_BA;
               counter = {1'b0,casLatency} - 1;
               latency = 1;
             end
    4'b0110: $display($time,"ns : Burst Terminate");
    4'b0111: begin
//               $display($time,"ns : Nop Command");
               if ((write == 1) && (counter != 0))
                 begin
                   counter = counter - 1;
                   if (counter == 0) write = 0;
                   else
                     begin
                       column = column + 1;
                       Memory[{row,column,bank}] = sdr_DQ;
					   write_count = write_count +1;
                       $display($time,
                         "ns :write: Bank=0x%h, Row=0x%h, Column=0x%h, Data=0x%h",
                         bank, row, column, sdr_DQ);
                     end
                 end
               else if ((read == 1) && (counter != 0))
                 begin
                   counter = counter - 1;
                   if (counter == 0)
                     begin
                       read = 0;
                       enableSdrDQ = #tOH 0;
                     end
                   else
                     begin
                       column = column + 1;
                       dataOut = #tAC Memory[{row,column,bank}];
					   read_count = read_count +1;
					   Memory_read[{row,column,bank}] = dataOut;
                       $display($time,
                         "ns : read: Bank=0x%h, Row=0x%h, Column=0x%h, Data=0x%h",
                         bank, row, column, dataOut);
						 
                     end
                 end
               else if ((latency == 1) && (counter != 0))
                 begin
                   counter = counter - 1;
                   if (counter == 0)
                     begin
                       latency = 0;
                       read = 1;
                       counter = burstLength;
                       dataOut = #tAC Memory[{row,column,bank}];
					   read_count = read_count +1;
					   Memory_read[{row,column,bank}] = dataOut;
                       enableSdrDQ = 1;
                       $display($time,
                         "ns : read: Bank=0x%h, Row=0x%h, Column=0x%h, Data=0x%h",
                         bank, row, column, dataOut);
                     end
                 end
             end
  endcase
reg flag;
integer i;
always @(posedge sdr_CK)
begin
flag=1;
if ((read_count == write_count) && (write_count != 0))
	begin
	
	for (i = 0; i < read_count; i = i+1)
		begin
		if (Memory[i] == Memory_read[i])
		begin 
			flag=1 & flag;
		end
		else
		begin
			flag=0 & flag;
		end
		end
		$display("------------------------------------------------------------");
	if (flag)
		$display("----------------------TEST PASS-----------------------------");
	else
		$display("----------------------TEST FAIL-----------------------------");
		
		$display("------------------------------------------------------------");
		
		
	$stop;
	end
end	
endmodule





module system(
  sys_CLK,
  sys_RESET,
  sys_A,
  sys_ADSn,
  sys_R_Wn,
  sys_D,
  sys_DLY_100US,
  sys_REF_REQ,
  sys_CYC_END,
  sys_INIT_DONE
);

// --------------------------------------------------------------------

parameter tDLY = 2; // 2ns delay for simulation purpose

//---------------------------------------------------------------------
// SDRAM mode register definition
//

// Write Burst Mode
parameter Programmed_Length = 1'b0;
parameter Single_Access     = 1'b1;

// Operation Mode
parameter Standard          = 2'b00;

// CAS Latency
parameter Latency_2         = 3'b010;
parameter Latency_3         = 3'b011;

// Burst Type
parameter Sequential        = 1'b0;
parameter Interleaved       = 1'b1;

// Burst Length
parameter Length_1          = 3'b000;
parameter Length_2          = 3'b001;
parameter Length_4          = 3'b010;
parameter Length_8          = 3'b011;

//---------------------------------------------------------------------
// User modifiable parameters
//

/****************************
* Mode register setting
****************************/

parameter MR_Write_Burst_Mode =    Programmed_Length;
                                // Single_Access;

parameter MR_Operation_Mode   =    Standard;

parameter MR_CAS_Latency      = // Latency_2;
                                   Latency_3;

parameter MR_Burst_Type       =    Sequential;
                                // Interleaved;

parameter MR_Burst_Length     = // Length_1;
                                // Length_2;
                                   Length_4;
                                // Length_8;

/****************************
* Bus width setting
****************************/

//
//           23 ......... 12     11 ....... 10      9 .........0
// sys_A  : MSB <-------------------------------------------> LSB
//
// Row    : RA_MSB <--> RA_LSB
// Bank   :                    BA_MSB <--> BA_LSB
// Column :                                       CA_MSB <--> CA_LSB
//

parameter RA_MSB = 22;
parameter RA_LSB = 11;

parameter BA_MSB = 10;
parameter BA_LSB =  9;

parameter CA_MSB =  8;
parameter CA_LSB =  0;

parameter SDR_BA_WIDTH =  2; // BA0,BA1
parameter SDR_A_WIDTH  = 12; // A0-A11

/****************************
* SDRAM AC timing spec
****************************/

//parameter tCK  = 12; //Comments by Zhipeng
parameter tCK  = 20;
parameter tMRD = 2*tCK;
parameter tRP  = 15;
parameter tRFC = 66;
parameter tRCD = 15;
parameter tWR  = tCK + 7;
parameter tDAL = tWR + tRP;

//---------------------------------------------------------------------
// Clock count definition for meeting SDRAM AC timing spec
//

parameter NUM_CLK_tMRD = tMRD/tCK;
parameter NUM_CLK_tRP  =  tRP/tCK;
parameter NUM_CLK_tRFC = tRFC/tCK;
parameter NUM_CLK_tRCD = tRCD/tCK;
parameter NUM_CLK_tDAL = tDAL/tCK;

// tDAL needs to be satisfied before the next sdram ACTIVE command can
// be issued. State c_tDAL of CMD_FSM is created for this purpose.
// However, states c_idle, c_ACTIVE and c_tRCD need to be taken into
// account because ACTIVE command will not be issued until CMD_FSM
// switch from c_ACTIVE to c_tRCD. NUM_CLK_WAIT is the version after
// the adjustment.
//parameter NUM_CLK_WAIT = (NUM_CLK_tDAL < 3) ? 0 : NUM_CLK_tDAL - 3;
parameter NUM_CLK_WAIT = 0;// (NUM_CLK_tDAL < 3) ? 0 : NUM_CLK_tDAL - 3;

//parameter NUM_CLK_CL    = (MR_CAS_Latency == Latency_2) ? 2 :
  //                        (MR_CAS_Latency == Latency_3) ? 3 :
    //
      //                    2;  // default
parameter NUM_CLK_CL    = 3;
//
//parameter NUM_CLK_READ  = (MR_Burst_Length == Length_1) ? 1 :
//                          (MR_Burst_Length == Length_2) ? 2 :
//                          (MR_Burst_Length == Length_4) ? 4 :
//                          (MR_Burst_Length == Length_8) ? 8 :
//                          4; // default
parameter NUM_CLK_READ  = 4;

//parameter NUM_CLK_WRITE = (MR_Burst_Length == Length_1) ? 1 :
//                          (MR_Burst_Length == Length_2) ? 2 :
//                          (MR_Burst_Length == Length_4) ? 4 :
//                          (MR_Burst_Length == Length_8) ? 8 :
//                          4; // default

parameter NUM_CLK_WRITE = 4;
//---------------------------------------------------------------------
// INIT_FSM state variable assignments (gray coded)
//

parameter i_NOP   = 4'b0000;
parameter i_PRE   = 4'b0001;
parameter i_tRP   = 4'b0010;
parameter i_AR1   = 4'b0011;
parameter i_tRFC1 = 4'b0100;
parameter i_AR2   = 4'b0101;
parameter i_tRFC2 = 4'b0110;
parameter i_MRS   = 4'b0111;
parameter i_tMRD  = 4'b1000;
parameter i_ready = 4'b1001;

//---------------------------------------------------------------------
// CMD_FSM state variable assignments (gray coded)
//

parameter c_idle   = 4'b0000;
parameter c_tRCD   = 4'b0001;
parameter c_cl     = 4'b0010;
parameter c_rdata  = 4'b0011;
parameter c_wdata  = 4'b0100;
parameter c_tRFC   = 4'b0101;
parameter c_tDAL   = 4'b0110;
parameter c_ACTIVE = 4'b1000;
parameter c_READA  = 4'b1001;
parameter c_WRITEA = 4'b1010;
parameter c_AR     = 4'b1011;

//---------------------------------------------------------------------
// SDRAM commands (sdr_CSn, sdr_RASn, sdr_CASn, sdr_WEn)
//

parameter INHIBIT            = 4'b1111;
parameter NOP                = 4'b0111;
parameter ACTIVE             = 4'b0011;
parameter READ               = 4'b0101;
parameter WRITE              = 4'b0100;
parameter BURST_TERMINATE    = 4'b0110;
parameter PRECHARGE          = 4'b0010;
parameter AUTO_REFRESH       = 4'b0001;
parameter LOAD_MODE_REGISTER = 4'b0000;



output        sys_CLK;
output        sys_RESET;
output [23:1] sys_A;
output        sys_ADSn;
output        sys_R_Wn;
output [15:0] sys_D;
output        sys_DLY_100US;
output        sys_REF_REQ;

input         sys_CYC_END;
input         sys_INIT_DONE;

wire           sys_CLK;
reg           sys_CLK_int;
reg           sys_CLK_en;
reg           sys_RESET;
reg [23:1]    sys_A;
reg           sys_ADSn;
reg           sys_R_Wn;
reg [15:0]    sys_D;
reg           sys_DLY_100US;
reg           sys_REF_REQ;

wire          sys_CYC_END;

//---------------------------------------------------------------------
// parameters -- change to whatever you like
//
parameter clock_time = 100;
parameter reset_time = 1000;

parameter sys_CLK_period = tCK;

//---------------------------------------------------------------------
// tasks
//
task write;
    input [23:1] addr;
    input [15:0] data;
  begin
    sys_A = addr;
    sys_ADSn = 0;
    sys_R_Wn = 0;
    #sys_CLK_period;
    sys_ADSn = 1;
    sys_D = data;
    #(sys_CLK_period * (NUM_CLK_WRITE + NUM_CLK_WAIT + 4));
    sys_D = 16'hzzzz;
    sys_R_Wn = 1;
    sys_A = 24'hzzzzzz;
  end
endtask

task read;
    input [23:1] addr;
  begin
    sys_A = addr;
    sys_ADSn = 0;
    sys_R_Wn = 1;
    #sys_CLK_period;
    sys_ADSn = 1;
    #(sys_CLK_period * (NUM_CLK_CL + NUM_CLK_READ + 3));
    sys_R_Wn = 1;
    sys_A = 24'hzzzzzz;
  end
endtask

//---------------------------------------------------------------------
// code
//
initial begin
    sys_R_Wn    <= #1 1'b1;
    sys_ADSn    <= #1 1'b1;
    sys_DLY_100US   <= #1 1'b0;
    sys_REF_REQ <= #1 1'b0;
    sys_CLK_int <= #1 1'b0;
    sys_RESET   <= #1 1'b1;
    sys_A       <= #1 24'hFFFFFF;
    sys_D       <= #1 16'hzzzz;
    sys_CLK_en  <= #1 1'b0;
    #clock_time;
    sys_CLK_en  <= #1 1'b1;
    #reset_time;
    @(posedge sys_CLK);
    $display($time,"ns : Coming Out Of Reset");
    sys_RESET    <= #1 1'b0;
    #100001;
    sys_DLY_100US    <= #1 1'b1;
    @(posedge sys_INIT_DONE);
    #500;
    @(negedge sys_CLK);
    write(23'h000000, 16'h1234);
    write(23'h000200, 16'h5678);
    write(23'h000400, 16'h9ABC);
    write(23'h000600, 16'hDEF0);
    read(23'h000000);
    read(23'h000200);
    read(23'h000400);
    read(23'h000600);
//    $stop;
end

always
    #(sys_CLK_period/2) sys_CLK_int <= ~sys_CLK_int;

assign sys_CLK = sys_CLK_en & sys_CLK_int;

endmodule

