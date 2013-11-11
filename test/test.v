`timescale 1ns / 1ps
`default_nettype none
  
`include "../src/uart.v"

`define CLKIN_HALF_PERIOD  5    //100MHz input clock
`define CLKOUT_HALF_PERIOD 4.17 //120MHz output clock
`define LEFT  0
`define RIGHT 1
  
module test;
    
  /* input */   
  reg CLK;
  reg RST_X;
    
  /* output */   
  // none
  
  initial begin
    CLK = 0;
    forever #(`CLKIN_HALF_PERIOD) CLK = ~CLK;
  end
    
  initial begin
    RST_X = 1;
    #1000;
    RST_X = 0;
    #1000;
    RST_X = 1;
  end
    
  top uut(CLK, RST_X);
    
  initial begin
    $dumpfile("uut.vcd");
    $dumpvars(0, uut);
  end

  initial begin
    #1000000;
    $finish;
  end
endmodule
    
module top (CLK, RST_X);
  input CLK;
  input RST_X;

  wire TX;
  wire RX;

  main # (.POSITION(`LEFT))
  left(CLK, RST_X, RX, TX); //left origin
  
  main # (.POSITION(`RIGHT))
  right(CLK, RST_X, TX, RX);
  
endmodule

module main(CLK_IN, RST_X_IN, RXD, TXD);
  parameter POSITION = 0; //0:left 1:right
  
  input CLK_IN, RST_X_IN, RXD;
  output TXD;
    
  wire CLK, RST_X;
  CLKGEN clkgen(CLK_IN, RST_X_IN, CLK, RST_X);
    
  reg we;
  reg init_left;
  reg init_right;
  reg init_done;
  reg [7:0] serdata;
  always @(posedge CLK or negedge RST_X) begin
    if (!RST_X) begin	 
	 we         <= 0;
	 init_left  <= 0;
	 init_right <= 0;
	 serdata    <= 0;
	 init_done  <= 0;
    end else if (POSITION == `LEFT && !(init_left)) begin
	 we         <= 1;
	 init_left  <= 1;
    end else if (POSITION == `RIGHT && !(init_right)) begin
	 serdata    <= 8'h61 - 1;
	 init_right <= 1;
    end else begin
	 init_done <= 1;
	 if (we) begin
	   serdata <= send_data;
	   $write("send data %x from ", send_data);
	   if (POSITION == `LEFT)  $write("left\n");
	   if (POSITION == `RIGHT) $write("right\n");
	 end
	 if (recv_data == serdata + 1 && en && !(we)) begin
	   we <= 1;
	 end else begin
	   we <= 0;
	 end
    end
  end

  wire [7:0] send_data = (POSITION == `LEFT && !init_done) ? 8'h61 : (we) ? recv_data + 1 : 0;
  
  wire ready;
  UartTx send(CLK, RST_X, send_data, we, TXD, ready); 
       
  wire [7:0] recv_data;
  wire       en;
  UartRx recv(CLK, RST_X, RXD, recv_data, en);
  
endmodule

/******************************************************************************/
/* Clock & Reset Generator                                                    */
/******************************************************************************/
module CLKGEN(CLK_I, RST_X_I, CLK_O, RST_X_O);
  input CLK_I, RST_X_I;
  output CLK_O, RST_X_O;

  wire LOCKED;
  clockgen clkgen(CLK_I, CLK_O, LOCKED);
  resetgen rstgen(CLK_O, (RST_X_I & LOCKED), RST_X_O);
endmodule

/******************************************************************************/
/* Clock Generator : 100MHz input clock -> output clock                       */
/******************************************************************************/
module clockgen(CLKIN_IN, CLKFX_OUT, LOCKED);
  input CLKIN_IN;
  output reg CLKFX_OUT, LOCKED;
  
  initial begin
    CLKFX_OUT = 0;
    forever #(`CLKOUT_HALF_PERIOD) CLKFX_OUT = ~CLKFX_OUT;
  end
  
  initial begin
    LOCKED = 1;
  end
  
endmodule

/******************************************************************************/
/* Reset Generator :  generate about 100 cycle reset signal                   */
/******************************************************************************/
module resetgen(CLK, RST_X_I, RST_X_O);
  input  CLK, RST_X_I;
  output RST_X_O;

  reg [7:0] cnt;
  assign RST_X_O = cnt[7];

  always @(posedge CLK or negedge RST_X_I) begin
    if      (!RST_X_I) cnt <= 0;
    else if (~RST_X_O) cnt <= (cnt + 1'b1);
  end
endmodule
/******************************************************************************/

`default_nettype wire
