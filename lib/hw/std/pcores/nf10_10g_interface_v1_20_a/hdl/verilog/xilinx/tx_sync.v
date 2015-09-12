///////////////////////////////////////////////////////////////////////////////
//   ____  ____ 
//  /   /\/   / 
// /___/  \  /    Vendor: Xilinx 
// \   \   \/     Version : 1.7
//  \   \         Application : RocketIO GTX Wizard 
//  /   /         Filename : tx_sync.v
// /___/   /\     Timestamp : 
// \   \  /  \ 
//  \___\/\___\ 
//
//
// Module TX_SYNC 
// Generated by Xilinx GTX Transceiver Wizard
// 
// 
// (c) Copyright 2008 - 2009 Xilinx, Inc. All rights reserved.
// 
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
// 
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES. 


`timescale 1ns / 1ps
`define DLY #1

module TX_SYNC  #(
  parameter         PLL_DIVSEL_OUT    =   1
)

(
  // User DRP Interface
  output  reg [16-1:0]            USER_DO,
  input       [16-1:0]            USER_DI,
  input       [7-1:0]             USER_DADDR,
  input                           USER_DEN,
  input                           USER_DWE,
  output  reg                     USER_DRDY,

  // GT DRP Interface 
  output      [16-1:0]            GT_DO,         // connects to DI of GTX_DUAL
  input       [16-1:0]            GT_DI,         // connects to DO of GTX_DUAL
  output  reg [7-1:0]             GT_DADDR,
  output  reg                     GT_DEN,
  output                          GT_DWE,
  input                           GT_DRDY,

  // Clocks and Reset
  input                           USER_CLK, 
  input                           DCLK,
  input                           RESET,
  input                           RESETDONE,
  
  // Phase Alignment ports to GT
  output                          TXENPMAPHASEALIGN,
  output                          TXPMASETPHASE,
  output  reg                     TXRESET,
  
  // SYNC operations 
  output                          SYNC_DONE,
  input                           RESTART_SYNC

);


parameter C_DRP_DWIDTH = 16;
parameter C_DRP_AWIDTH = 7;

//*******************************Register Declarations************************
// USER_CLK domain

reg   [1:0]             reset_usrclk_r; // reset to SYNC FSM
reg                     dclk_fsms_rdy_r; // trigger to move to start_drp state 
reg                     dclk_fsms_rdy_r2; // trigger to move to start_drp state 
reg   [6:0]             sync_state;
reg   [6:0]             sync_next_state;
reg   [40*7:0]          sync_fsm_name;
reg                     revert_drp;
reg                     start_drp;
reg                     start_drp_done_r2;
reg                     start_drp_done_r;
reg                     txreset_done_r;
reg                     revert_drp_done_r2;
reg                     revert_drp_done_r;
reg                     phase_align_done_r;
reg   [15:0]            sync_counter_r;
reg                     en_phase_align_r;
reg                     set_phase_r;
reg   [5:0]             wait_before_sync_r;
reg                     restart_sync_r2;
reg                     restart_sync_r;
reg                     resetdone_r;
reg                     resetdone_r2;

 // synthesis attribute fsm_encoding of sync_state is one-hot;

 // synthesis attribute ASYNC_REG of dclk_fsms_rdy_r is "TRUE";
 // synthesis attribute ASYNC_REG of start_drp_done_r is "TRUE";
 // synthesis attribute ASYNC_REG of revert_drp_done_r is "TRUE";
 // synthesis attribute ASYNC_REG of restart_sync_r is "TRUE";
 // synthesis attribute ASYNC_REG of resetdone_r is "TRUE";
 // synthesis attribute ASYNC_REG of reset_usrclk_r is "TRUE";
//  synthesis attribute ASYNC_REG of reset_dclk_r   is "TRUE";

// DCLK domain

reg   [1:0]             reset_dclk_r; // reset to DRP, XD and DB FSMs
reg  [C_DRP_DWIDTH-1:0] user_di_r = {C_DRP_DWIDTH{1'b0}};
reg  [C_DRP_AWIDTH-1:0] user_daddr_r = {C_DRP_AWIDTH{1'b0}};
reg                     user_den_r;
reg                     user_req;
reg                     user_dwe_r;
reg                     xd_req = 1'b0;
reg                     xd_read = 1'b0;
reg                     xd_write = 1'b0;
reg                     xd_drp_done = 1'b0;
reg  [C_DRP_DWIDTH-1:0] xd_wr_wreg = {C_DRP_DWIDTH{1'b0}};
reg  [C_DRP_AWIDTH-1:0] xd_addr_r;
reg                     gt_drdy_r = 1'b0;
reg [C_DRP_DWIDTH-1:0]  gt_do_r = {C_DRP_DWIDTH{1'b0}};
reg   [3:0]             db_state;
reg   [3:0]             db_next_state;
reg   [5:0]             drp_state;
reg   [5:0]             drp_next_state;
reg   [15:0]            xd_state;
reg   [15:0]            xd_next_state;
reg   [40*7:0]          db_fsm_name;
reg   [40*7:0]          drp_fsm_name;
reg   [40*7:0]          xd_fsm_name;
reg                     revert_drp_r2;
reg                     revert_drp_r;
reg                     start_drp_r2;
reg                     start_drp_r;

  // synthesis attribute fsm_encoding of db_state is one-hot;
  // synthesis attribute fsm_encoding of drp_state is one-hot;
  // synthesis attribute fsm_encoding of xd_state is one-hot;

  // synthesis attribute ASYNC_REG of start_drp_r is "TRUE";
  // synthesis attribute ASYNC_REG of revert_drp_r is "TRUE";

//*******************************Wire Declarations****************************

wire [C_DRP_AWIDTH-1:0] c_tx_xclk0_addr;
wire [C_DRP_AWIDTH-1:0] c_tx_xclk1_addr;
wire                    user_sel;
wire                    xd_sel;
wire                    drp_rd;
wire                    drp_wr;
wire                    db_fsm_rdy;
wire                    drp_fsm_rdy;
wire                    xd_fsm_rdy;
wire                    dclk_fsms_rdy;
wire                    revert_drp_done;
wire                    start_drp_done;
wire                    count_setphase_complete_r;
wire                    txreset_i;


//----------------------------------------------------------------------------
// Arbitration FSM - Blocks User DRP Access when SYNC DRP operation 
// is in progress
//----------------------------------------------------------------------------
parameter C_RESET           = 4'b0001;
parameter C_IDLE            = 4'b0010;
parameter C_XD_DRP_OP       = 4'b0100;
parameter C_USER_DRP_OP     = 4'b1000;


//----------------------------------------------------------------------------
// DRP FSM
//----------------------------------------------------------------------------
parameter C_DRP_RESET       = 6'b000001;
parameter C_DRP_IDLE        = 6'b000010;
parameter C_DRP_READ        = 6'b000100;
parameter C_DRP_WRITE       = 6'b001000;
parameter C_DRP_WAIT        = 6'b010000;
parameter C_DRP_COMPLETE    = 6'b100000;


//----------------------------------------------------------------------------
// XCLK_SEL DRP FSM
//----------------------------------------------------------------------------
parameter C_XD_RESET              = 16'b0000000000000001;
parameter C_XD_IDLE               = 16'b0000000000000010;
parameter C_XD_RD_XCLK0_TXUSR     = 16'b0000000000000100;
parameter C_XD_MD_XCLK0_TXUSR     = 16'b0000000000001000;
parameter C_XD_WR_XCLK0_TXUSR     = 16'b0000000000010000;
parameter C_XD_RD_XCLK1_TXUSR     = 16'b0000000000100000;
parameter C_XD_MD_XCLK1_TXUSR     = 16'b0000000001000000;
parameter C_XD_WR_XCLK1_TXUSR     = 16'b0000000010000000;
parameter C_XD_WAIT               = 16'b0000000100000000;
parameter C_XD_RD_XCLK0_TXOUT     = 16'b0000001000000000;
parameter C_XD_MD_XCLK0_TXOUT     = 16'b0000010000000000;
parameter C_XD_WR_XCLK0_TXOUT     = 16'b0000100000000000;
parameter C_XD_RD_XCLK1_TXOUT     = 16'b0001000000000000;
parameter C_XD_MD_XCLK1_TXOUT     = 16'b0010000000000000;
parameter C_XD_WR_XCLK1_TXOUT     = 16'b0100000000000000;
parameter C_XD_DONE               = 16'b1000000000000000;  

//----------------------------------------------------------------------------
// SYNC FSM
//----------------------------------------------------------------------------
parameter C_SYNC_IDLE               = 7'b0000001;
parameter C_SYNC_START_DRP          = 7'b0000010;
parameter C_SYNC_PHASE_ALIGN        = 7'b0000100;
parameter C_SYNC_REVERT_DRP         = 7'b0001000;
parameter C_SYNC_TXRESET            = 7'b0010000;
parameter C_SYNC_WAIT_RESETDONE     = 7'b0100000;
parameter C_SYNC_DONE               = 7'b1000000;

//----------------------------------------------------------------------------
// Make Addresses for GTX0 or GTX1 at compile time
//----------------------------------------------------------------------------
parameter C_GTX0_TX_XCLK_ADDR     = 7'h3A;
parameter C_GTX1_TX_XCLK_ADDR     = 7'h15;

assign c_tx_xclk0_addr    = C_GTX0_TX_XCLK_ADDR;
assign c_tx_xclk1_addr    = C_GTX1_TX_XCLK_ADDR;


//----------------------------------------------------------------------------
// Sync RESET to USER_CLK and DCLK domain
//----------------------------------------------------------------------------
always @(posedge DCLK or posedge RESET)
  if (RESET)
    reset_dclk_r <= 2'b11;
  else
    reset_dclk_r <= {1'b0, reset_dclk_r[1]};

always @(posedge USER_CLK or posedge RESET)
  if (RESET)
    reset_usrclk_r <= 2'b11;
  else
    reset_usrclk_r <= {1'b0, reset_usrclk_r[1]};


//----------------------------------------------------------------------------
// User DRP Transaction Capture Input Registers
//----------------------------------------------------------------------------
// User Data Input
always @ (posedge DCLK)
begin
  if (reset_dclk_r[0])
    user_di_r <= 1'b0;
  else if (USER_DEN)
    user_di_r <= USER_DI;
end

// User DRP Address
always @ (posedge DCLK)
begin
  if (reset_dclk_r[0])
    user_daddr_r <= 7'b0;
  else if (USER_DEN)
    user_daddr_r <= USER_DADDR[C_DRP_AWIDTH-1:0];
end

// User Data Write Enable
always @ (posedge DCLK)
  if (reset_dclk_r[0])
    user_dwe_r <= 1'b0;
  else if (USER_DEN)
    user_dwe_r <= USER_DWE;

// Register the user_den_r when the user is granted access from the
// Arbitration FSM
always @ (posedge DCLK)
  if (reset_dclk_r[0] | (db_state==C_USER_DRP_OP))
    user_den_r <= 1'b0;
  else if (~user_den_r)
    user_den_r <= USER_DEN;

// Generate the user request (user_req) signal when the user is not accessing
// the same DRP addresses as the deskew Block or when the deskew
// Block is in idle or done states.
always @ (posedge DCLK)
  if (reset_dclk_r[0] | (db_state==C_USER_DRP_OP))
    user_req <= 1'b0;
  else if ( 
            ~(user_daddr_r==c_tx_xclk0_addr) &
            ~(user_daddr_r==c_tx_xclk1_addr))
    user_req <= user_den_r;
  else if (xd_state==C_XD_IDLE || xd_state==C_XD_DONE)
    user_req <= user_den_r;

// User Data Output
always @ (posedge DCLK)
  if ( (db_state == C_USER_DRP_OP) & GT_DRDY)
    USER_DO <= GT_DI;

// User Data Ready
always @ (posedge DCLK)
  if (reset_dclk_r[0] | USER_DRDY)
    USER_DRDY <= 1'b0;
  else if ( (db_state==C_USER_DRP_OP) )
    USER_DRDY <= GT_DRDY;

//----------------------------------------------------------------------------
// GT DRP Interface
//----------------------------------------------------------------------------
// GT Data Output: the data output is generated either from a XCLK_SEL DRP
// FSM operation, an Auto deskew FSM operation, or a user access.
always @(posedge DCLK)
  casez( {xd_sel,user_sel} )
    2'b1?: gt_do_r <= xd_wr_wreg;
    2'b01: gt_do_r <= user_di_r;
  endcase

assign GT_DO = gt_do_r;

// GT DRP Address: the DRP address is generated either from a XCLK_SEL DRP  
// FSM operation, or a user access.  DRP address ranges from 0x40 to 0x7F.
always @(posedge DCLK)
begin
  casez( {xd_sel, user_sel})
    2'b1?: GT_DADDR <= xd_addr_r;
    2'b01: GT_DADDR <= user_daddr_r;
  endcase
end

// GT Data Enable: the data enable is generated whenever there is a DRP
// Read or a DRP Write
always @(posedge DCLK)
  if (reset_dclk_r[0])
    GT_DEN <= 1'b0;
  else
    GT_DEN <= (drp_state==C_DRP_IDLE) & (drp_wr | drp_rd);

// GT Data Write Enable
assign GT_DWE = (drp_state==C_DRP_WRITE);

// GT Data Ready
always @(posedge DCLK)
  gt_drdy_r <= GT_DRDY;




//----------------------------------------------------------------------------
// SYNC FSM Internal Logic
// 1. Trigger DRP operation to change TX_XCLK_SEL to "TXUSR"
// 2. Perform Phase Alignment by asserting PMASETPHASE, ENPMAPHASEALIGN ports
// 3. Trigger DRP operation to change TX_XCLK_SEL back to "TXOUT"
// 4. Apply TXRESET, wait for RESETDONE to go High and assert SYNC_DONE
//----------------------------------------------------------------------------
assign dclk_fsms_rdy = db_fsm_rdy & xd_fsm_rdy & drp_fsm_rdy;

always @(posedge USER_CLK)
begin
  if (dclk_fsms_rdy)
    dclk_fsms_rdy_r <= 1'b1;
  else
    dclk_fsms_rdy_r <= 1'b0;
end

always @(posedge USER_CLK)
    dclk_fsms_rdy_r2 <= dclk_fsms_rdy_r;

// Generate a signal to trigger drp operation of changing XCLK_SEL to TXUSR
always @(posedge USER_CLK)
begin
  if (sync_state == C_SYNC_START_DRP)
    start_drp <= 1'b1;
  else  
    start_drp <= 1'b0;
end

// Capture start_drp_done(DCLK) signal on USER_CLK domain
always @(posedge USER_CLK)
begin
  if (reset_usrclk_r[0])
    start_drp_done_r <= 1'b0;
  else if (start_drp_done)
    start_drp_done_r <= 1'b1;
  else 
    start_drp_done_r <= 1'b0;
end    

always @(posedge USER_CLK)
    start_drp_done_r2 <= start_drp_done_r;

// Perform Phase Align operations in C_SYNC_PHASE_ALIGN state
// Assert TXENPMAPHASEALIGN in C_SYNC_PHASE_ALIGN state
// Once asserted, TXENPMAPHASEALIGN is deasserted only when
// the state machine moves back to C_SYNC_IDLE
always @(posedge USER_CLK)
begin
  if ( reset_usrclk_r[0] | (sync_state == C_SYNC_IDLE) )
     en_phase_align_r <= 1'b0;
  else if (sync_state == C_SYNC_PHASE_ALIGN)
     en_phase_align_r <= 1'b1;
end

assign TXENPMAPHASEALIGN = en_phase_align_r;

// Assert set_phase_r in C_SYNC_PHASE ALIGN state after waiting for 
// 32 cycles. set_phase_r is deasserted after setphase count is complete
always @(posedge USER_CLK)
begin
  if ( reset_usrclk_r[0] | ~en_phase_align_r )
    wait_before_sync_r <= `DLY  6'b000000;
  else if( ~wait_before_sync_r[5] )
    wait_before_sync_r <= `DLY  wait_before_sync_r + 1'b1;
end

always @(posedge USER_CLK)
begin
  if ( ~wait_before_sync_r[5] )
    set_phase_r <= 1'b0;
  else if ( ~count_setphase_complete_r & (sync_state == C_SYNC_PHASE_ALIGN) )
    set_phase_r <= 1'b1;
  else  
    set_phase_r <= 1'b0;
end

// Assign PMASETPHASE to set_phase_r
assign TXPMASETPHASE = set_phase_r;

// Counter for holding SYNC for SYNC_CYCLES 
always @(posedge USER_CLK)
begin
 if ( reset_usrclk_r[0] | ~(sync_state == C_SYNC_PHASE_ALIGN) )
   sync_counter_r <= `DLY  16'h0000;
 else if (set_phase_r)
   sync_counter_r <= `DLY  sync_counter_r + 1'b1;
end

generate
if (PLL_DIVSEL_OUT==1)
begin : pll_divsel_out_equals_1 
// 8192 cycles of setphase for output divider of 1
  assign count_setphase_complete_r = sync_counter_r[13];
end
else if (PLL_DIVSEL_OUT==2)
begin :pll_divsel_out_equals_2
// 16384 cycles of setphase for output divider of 2
  assign count_setphase_complete_r = sync_counter_r[14];
end
else 
begin :pll_divsel_out_equals_4
// 32768 cycles of setphase for output divider of 4
  assign count_setphase_complete_r = sync_counter_r[15];
end
endgenerate

// Assert phase_align_done_r when setphase count is complete
always @(posedge USER_CLK)
begin
  if (reset_usrclk_r[0])
    phase_align_done_r <= 1'b0;
  else 
    phase_align_done_r <= set_phase_r & count_setphase_complete_r;
end

// Generate a signal to trigger drp operation to revert XCLK_SEL back to TXOUT
always @(posedge USER_CLK)
begin
  if (reset_usrclk_r[0])
    revert_drp <= 1'b0;
  else if (sync_state == C_SYNC_REVERT_DRP)
    revert_drp <= 1'b1;
  else  
    revert_drp <= 1'b0;
end

// Capture revert_drp_done(DCLK) signal on USER_CLK domain
always @(posedge USER_CLK)
begin
  if (reset_usrclk_r[0])
    revert_drp_done_r <= 1'b0;
  else if (revert_drp_done)
    revert_drp_done_r <= 1'b1;
  else 
    revert_drp_done_r <= 1'b0;
end    

always @(posedge USER_CLK)
    revert_drp_done_r2 <= revert_drp_done_r;

// Assert txreset_i in C_SYNC_TXRESET state
assign txreset_i = (sync_state == C_SYNC_TXRESET);

// Register txreset_i on USER_CLK
always @(posedge USER_CLK)
  TXRESET <= txreset_i;

always @(posedge USER_CLK)
begin
  if (reset_usrclk_r[0])
    txreset_done_r <= 1'b0;
  else if ((sync_state == C_SYNC_TXRESET) & ~resetdone_r2)  
    txreset_done_r <= 1'b1;
  else  
    txreset_done_r <= 1'b0;
end

// Capture RESETDONE on USER_CLK
always @(posedge USER_CLK)
begin
  if (RESETDONE)  
    resetdone_r <= 1'b1;
  else
    resetdone_r <= 1'b0;
end

always @(posedge USER_CLK)
  resetdone_r2 <= resetdone_r;

// Capture RESTART_SYNC on USER_CLK
always @(posedge USER_CLK)
begin
  if (RESTART_SYNC)  
    restart_sync_r <= 1'b1;
  else
    restart_sync_r <= 1'b0;
end

always @(posedge USER_CLK)
  restart_sync_r2 <= restart_sync_r;

assign SYNC_DONE = (sync_state == C_SYNC_DONE);

//----------------------------------------------------------------------------
// SYNC FSM
//----------------------------------------------------------------------------
always @(posedge USER_CLK)
begin
  if (reset_usrclk_r[0])
    sync_state <= C_SYNC_IDLE;
  else
    sync_state <= sync_next_state;
end

always @*
begin
  case (sync_state)
    C_SYNC_IDLE: begin
      sync_next_state <= dclk_fsms_rdy_r2 ? C_SYNC_START_DRP : C_SYNC_IDLE;
      sync_fsm_name = "C_SYNC_IDLE";
    end

    C_SYNC_START_DRP: begin
      sync_next_state <= start_drp_done_r2 ? C_SYNC_PHASE_ALIGN : C_SYNC_START_DRP;
      sync_fsm_name = "C_SYNC_START_DRP";
    end

    C_SYNC_PHASE_ALIGN: begin
      sync_next_state <= phase_align_done_r ? C_SYNC_REVERT_DRP : C_SYNC_PHASE_ALIGN;
      sync_fsm_name = "C_SYNC_PHASE_ALIGN";
    end

    C_SYNC_REVERT_DRP: begin
      sync_next_state <= revert_drp_done_r2 ? C_SYNC_TXRESET : C_SYNC_REVERT_DRP;
      sync_fsm_name = "C_SYNC_REVERT_DRP";
    end

    C_SYNC_TXRESET: begin
      sync_next_state <= txreset_done_r ? C_SYNC_WAIT_RESETDONE : C_SYNC_TXRESET;
      sync_fsm_name = "C_SYNC_TXRESET";
    end
    
    C_SYNC_WAIT_RESETDONE: begin
      sync_next_state <= resetdone_r2 ? C_SYNC_DONE : C_SYNC_WAIT_RESETDONE;
      sync_fsm_name = "C_SYNC_WAIT_RESETDONE"; 
    end
    
    C_SYNC_DONE: begin
      sync_next_state <= restart_sync_r2 ? C_SYNC_IDLE : C_SYNC_DONE;
      sync_fsm_name = "C_SYNC_DONE";
    end
    
    default: begin
      sync_next_state <= C_SYNC_IDLE;
      sync_fsm_name = "default";
    end

  endcase
end


//----------------------------------------------------------------------------
// deskew Block Internal Logic:  The different select signals are
// generated for a user DRP operations as well as internal deskew Block
// accesses.
//----------------------------------------------------------------------------
assign xd_sel = (db_state == C_XD_DRP_OP);
assign user_sel = (db_state == C_USER_DRP_OP);
assign db_fsm_rdy = ~(db_state == C_RESET);

//----------------------------------------------------------------------------
// deskew Block (DB) FSM
//----------------------------------------------------------------------------
always @(posedge DCLK)
begin
  if (reset_dclk_r[0])
    db_state <= C_RESET;
  else
    db_state <= db_next_state;
end

always @*
begin
  case (db_state)
    C_RESET: begin
      db_next_state <= C_IDLE;
      db_fsm_name = "C_RESET";
    end

    C_IDLE: begin
      if (xd_req)         db_next_state <= C_XD_DRP_OP;
      else if (user_req)  db_next_state <= C_USER_DRP_OP;
      else                db_next_state <= C_IDLE;
      db_fsm_name = "C_IDLE";
    end

    C_XD_DRP_OP: begin
      db_next_state <= gt_drdy_r ? C_IDLE : C_XD_DRP_OP;
      db_fsm_name = "C_XD_DRP_OP";
    end

    C_USER_DRP_OP: begin
      db_next_state <= gt_drdy_r ? C_IDLE : C_USER_DRP_OP;
      db_fsm_name = "C_USER_DRP_OP";
    end

    default: begin
      db_next_state <= C_IDLE;
      db_fsm_name = "default";
    end

  endcase
end

//----------------------------------------------------------------------------
// XCLK_SEL DRP Block Internal Logic
//----------------------------------------------------------------------------
// Request for DRP operation
always @(posedge DCLK)
begin
  if ((xd_state == C_XD_IDLE) | xd_drp_done)
    xd_req <= 1'b0;
  else
    xd_req <= xd_read | xd_write;
end

// Indicates DRP Read
always @(posedge DCLK)
begin
  if ((xd_state == C_XD_IDLE) | xd_drp_done)
    xd_read <= 1'b0;
  else
    xd_read <=  (xd_state == C_XD_RD_XCLK0_TXUSR) |
                (xd_state == C_XD_RD_XCLK1_TXUSR) |
                (xd_state == C_XD_RD_XCLK0_TXOUT) |
                (xd_state == C_XD_RD_XCLK1_TXOUT);
end

// Indicates Detect DRP Write
always @(posedge DCLK)
begin
  if ((xd_state == C_XD_IDLE) | xd_drp_done)
    xd_write <= 1'b0;
  else
    xd_write <= (xd_state == C_XD_WR_XCLK0_TXUSR) |
                (xd_state == C_XD_WR_XCLK1_TXUSR) |
                (xd_state == C_XD_WR_XCLK0_TXOUT) |
                (xd_state == C_XD_WR_XCLK1_TXOUT);
end

// Detect DRP Write Working Register
//TODO: Add check for txrx_invert bits as well
always @(posedge DCLK)
begin
  if ((db_state == C_XD_DRP_OP) & xd_read & GT_DRDY)
    xd_wr_wreg <= GT_DI;
  else begin
    case (xd_state)
      C_XD_MD_XCLK0_TXUSR:
        xd_wr_wreg <= {xd_wr_wreg[15:9], 1'b1, xd_wr_wreg[7:0]};
      C_XD_MD_XCLK1_TXUSR:
        xd_wr_wreg <= {xd_wr_wreg[15:8], 1'b1, xd_wr_wreg[6:0]};
      C_XD_MD_XCLK0_TXOUT:
        xd_wr_wreg <= {xd_wr_wreg[15:9], 1'b0, xd_wr_wreg[7:0]};
      C_XD_MD_XCLK1_TXOUT:
        xd_wr_wreg <= {xd_wr_wreg[15:8], 1'b0, xd_wr_wreg[6:0]};
    endcase
  end
end

// Generate DRP Addresses 
always @*
begin
  case (xd_state)
    C_XD_RD_XCLK0_TXUSR:  xd_addr_r <= c_tx_xclk0_addr;
    C_XD_WR_XCLK0_TXUSR:  xd_addr_r <= c_tx_xclk0_addr;
    C_XD_RD_XCLK0_TXOUT:  xd_addr_r <= c_tx_xclk0_addr;
    C_XD_WR_XCLK0_TXOUT:  xd_addr_r <= c_tx_xclk0_addr;
    C_XD_RD_XCLK1_TXUSR:  xd_addr_r <= c_tx_xclk1_addr;
    C_XD_WR_XCLK1_TXUSR:  xd_addr_r <= c_tx_xclk1_addr;
    C_XD_RD_XCLK1_TXOUT:  xd_addr_r <= c_tx_xclk1_addr;
    C_XD_WR_XCLK1_TXOUT:  xd_addr_r <= c_tx_xclk1_addr;
    default:              xd_addr_r <= c_tx_xclk0_addr;
  endcase
end

// Assert DRP DONE when DRP Operation is Complete
always @(posedge DCLK)
  xd_drp_done <= GT_DRDY & (db_state==C_XD_DRP_OP);

// Assert xd_fsm_rdy when xd_state is not C_XD_RESET
assign xd_fsm_rdy = ~(xd_state == C_XD_RESET);

// Generate a start_drp_r2 on DCLK domain from start_drp(USER_CLK)
always @(posedge DCLK)
begin
  if (reset_dclk_r[0])
    start_drp_r <= 1'b0; 
  else if (start_drp)
    start_drp_r <= 1'b1;
  else  
    start_drp_r <= 1'b0; 
end

always @(posedge DCLK)
    start_drp_r2 <= start_drp_r;

// Assert start_drp_done when xd_state is C_XD_WAIT
assign start_drp_done = (xd_state == C_XD_WAIT);

// Generate a revert_drp_r2 on DCLK domain from revert_drp(USER_CLK)
always @(posedge DCLK)
begin
  if (reset_dclk_r[0])
    revert_drp_r <= 1'b0; 
  else if (revert_drp)
    revert_drp_r <= 1'b1;
  else  
    revert_drp_r <= 1'b0; 
end

always @(posedge DCLK)
    revert_drp_r2 <= revert_drp_r;

// Assert revert_drp_done when xd_state is C_XD_DONE
assign revert_drp_done = (xd_state == C_XD_DONE);


//----------------------------------------------------------------------------
// XCLK_SEL DRP FSM:  The XD FSM is triggered by the SYNC FSM
//----------------------------------------------------------------------------
always @(posedge DCLK)
begin
  if (reset_dclk_r[0])
    xd_state <= C_XD_RESET;
  else
    xd_state <= xd_next_state;
end

always @*
begin
  case (xd_state)
    C_XD_RESET: begin
      xd_next_state <= C_XD_IDLE;
      xd_fsm_name = "C_XD_RESET";
    end
    
    C_XD_IDLE: begin
      if (start_drp_r2)
        xd_next_state <= C_XD_RD_XCLK0_TXUSR;
      else
        xd_next_state <= C_XD_IDLE;
      xd_fsm_name = "C_XD_IDLE";
    end

    C_XD_RD_XCLK0_TXUSR: begin
      xd_next_state <= xd_drp_done ? C_XD_MD_XCLK0_TXUSR :
                                     C_XD_RD_XCLK0_TXUSR;
      xd_fsm_name = "C_XD_RD_XCLK0_TXUSR";
    end

    C_XD_MD_XCLK0_TXUSR: begin
      xd_next_state <= C_XD_WR_XCLK0_TXUSR;
      xd_fsm_name = "C_XD_MD_XCLK0_TXUSR";
    end

    C_XD_WR_XCLK0_TXUSR: begin
      xd_next_state <= xd_drp_done ? C_XD_RD_XCLK1_TXUSR : C_XD_WR_XCLK0_TXUSR;
      xd_fsm_name = "C_XD_WR_XCLK0_TXUSR";
    end

    C_XD_RD_XCLK1_TXUSR: begin
      xd_next_state <= xd_drp_done ? C_XD_MD_XCLK1_TXUSR : C_XD_RD_XCLK1_TXUSR;
      xd_fsm_name = "C_XD_RD_XCLK1_TXUSR";
    end

    C_XD_MD_XCLK1_TXUSR: begin
      xd_next_state <= C_XD_WR_XCLK1_TXUSR;
      xd_fsm_name = "C_XD_MD_XCLK1_TXUSR";
    end

    C_XD_WR_XCLK1_TXUSR: begin
      xd_next_state <= xd_drp_done ? C_XD_WAIT: C_XD_WR_XCLK1_TXUSR;
      xd_fsm_name = "C_XD_WR_XCLK1_TXUSR";
    end

    C_XD_WAIT: begin
      xd_next_state <= revert_drp_r2 ? C_XD_RD_XCLK0_TXOUT : C_XD_WAIT;
      xd_fsm_name = "C_XD_WAIT";
    end

    C_XD_RD_XCLK0_TXOUT: begin
      xd_next_state <= xd_drp_done ?
                        C_XD_MD_XCLK0_TXOUT : C_XD_RD_XCLK0_TXOUT;
      xd_fsm_name = "C_XD_RD_XCLK0_TXOUT";
    end

    C_XD_MD_XCLK0_TXOUT: begin
      xd_next_state <= C_XD_WR_XCLK0_TXOUT;
      xd_fsm_name = "C_XD_MD_XCLK0_TXOUT";
    end

    C_XD_WR_XCLK0_TXOUT: begin
      xd_next_state <= xd_drp_done ? C_XD_RD_XCLK1_TXOUT : C_XD_WR_XCLK0_TXOUT;
      xd_fsm_name = "C_XD_WR_XCLK0_TXOUT";
    end

    C_XD_RD_XCLK1_TXOUT: begin
      xd_next_state <= xd_drp_done ? C_XD_MD_XCLK1_TXOUT : C_XD_RD_XCLK1_TXOUT;
      xd_fsm_name = "C_XD_RD_XCLK1_TXOUT";
    end

    C_XD_MD_XCLK1_TXOUT: begin
      xd_next_state <= C_XD_WR_XCLK1_TXOUT;
      xd_fsm_name = "C_XD_MD_XCLK1_TXOUT";
    end

    C_XD_WR_XCLK1_TXOUT: begin
      xd_next_state <= xd_drp_done ? C_XD_DONE : C_XD_WR_XCLK1_TXOUT;
      xd_fsm_name = "C_XD_WR_XCLK1_TXOUT";
    end

    C_XD_DONE: begin
      xd_next_state <= ~revert_drp_r2 ? C_XD_IDLE : C_XD_DONE;
      xd_fsm_name = "C_XD_DONE";
    end

    default: begin
      xd_next_state <= C_XD_IDLE;
      xd_fsm_name = "default";
    end

  endcase
end


//----------------------------------------------------------------------------
// DRP Read/Write FSM
//----------------------------------------------------------------------------
// Generate a read signal for the DRP
assign drp_rd = ((db_state == C_XD_DRP_OP) & xd_read) |
                ((db_state == C_USER_DRP_OP) & ~user_dwe_r); 

// Generate a write signal for the DRP
assign drp_wr = ((db_state == C_XD_DRP_OP) & xd_write) |
                ((db_state == C_USER_DRP_OP) & user_dwe_r);

     
assign drp_fsm_rdy = ~(drp_state == C_DRP_RESET);

always @(posedge DCLK)
begin
  if (reset_dclk_r[0])
    drp_state <= C_DRP_RESET;
  else
    drp_state <= drp_next_state;
end

always @*
begin
  case (drp_state)
    C_DRP_RESET: begin
      drp_next_state <= C_DRP_IDLE;
      drp_fsm_name = "C_DRP_RESET";
    end 
    
    C_DRP_IDLE: begin
      drp_next_state <= drp_wr ? C_DRP_WRITE : (drp_rd?C_DRP_READ:C_DRP_IDLE);
      drp_fsm_name = "C_DRP_IDLE";
    end

    C_DRP_READ: begin
      drp_next_state <= C_DRP_WAIT;
      drp_fsm_name = "C_DRP_READ";
    end

    C_DRP_WRITE: begin
      drp_next_state <= C_DRP_WAIT;
      drp_fsm_name = "C_DRP_WRITE";
    end

    C_DRP_WAIT: begin
      drp_next_state <= gt_drdy_r ? C_DRP_COMPLETE : C_DRP_WAIT;
      drp_fsm_name = "C_DRP_WAIT";
    end

    C_DRP_COMPLETE: begin
      drp_next_state <= C_DRP_IDLE;
      drp_fsm_name = "C_DRP_COMPLETE";
    end

    default: begin
      drp_next_state <= C_DRP_IDLE;
      drp_fsm_name = "default";
    end

  endcase
end

endmodule
