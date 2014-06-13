`timescale 1ns / 1ps
`default_nettype none
  
`include "define.v"
`include "uart.v"

`define CLKIN_HALF_PERIOD  (1000/`SYSTEM_CLOCK_FREQ/2)
`define CLKOUT_HALF_PERIOD (1000/`CLOCK_FREQ/2)
`define LEFT  0
`define RIGHT 1
`define INIT_VALUE 8'h61  // ascii 'a'
  
module test;
    
  /* input */   
  reg CLK;
  reg RST_X;
    
  /* output */   
  // none
  
  top uut(CLK, RST_X);
  
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
  initial begin
    $dumpfile("uut.vcd");
    $dumpvars(0, uut);
  end
  
endmodule
    
module top (input wire CLK, 
            input wire RST_X);

  wire TX;
  wire RX;

  main # (.POSITION(`LEFT))
  left(CLK, RST_X, RX, TX); //left origin
  
  main # (.POSITION(`RIGHT))
  right(CLK, RST_X, TX, RX);
  
endmodule

module main(input  wire CLK_IN, 
            input  wire RST_X_IN, 
            input  wire RXD, 
            output wire TXD);
  
  parameter POSITION = 0; //0:left 1:right
  
  wire CLK, RST_X;
  CLKGEN clkgen(CLK_IN, RST_X_IN, CLK, RST_X);
    
  reg we;
  reg init_left;
  reg init_done;
  always @(posedge CLK) begin
    if (!RST_X) begin	 
	 we         <= 0;
	 init_left  <= 0;
	 init_done  <= 0;
    end else if (POSITION == `LEFT && !(init_left)) begin
	 if (ready) begin
	   we         <= 1;
	   init_left  <= 1;
	 end
    end else begin
	 if (!init_done) init_done <= 1;
	 we <= (en && !(we) && ready);
	 if (recv_data == 8'h7a) $finish;  // if recv_data is 'z', this simulation is terminated.
	 if (we) begin
	   $write("send data %x from ", send_data);
	   if (POSITION == `LEFT)  $write("left\n");
	   if (POSITION == `RIGHT) $write("right\n");
	 end
    end
  end

  wire [7:0] send_data = (!init_done && we) ? `INIT_VALUE : 
                                       (we) ? recv_data + 1 : 0;
  
  wire ready;
  UartTx send(CLK, RST_X, we, send_data, TXD, ready); 
       
  wire [7:0] recv_data;
  wire       en;
  UartRx recv(CLK, RST_X, RXD, recv_data, en);
  
endmodule

/******************************************************************************/
/* Clock & Reset Generator                                                    */
/******************************************************************************/
module CLKGEN(input  wire CLK_I, 
              input  wire RST_X_I, 
              output wire CLK_O, 
              output wire RST_X_O);

  wire LOCKED;
  clockgen clkgen(CLK_I, CLK_O, LOCKED);
  resetgen rstgen(CLK_O, (RST_X_I & LOCKED), RST_X_O);
endmodule

/******************************************************************************/
/* Clock Generator : 100MHz input clock -> output clock                       */
/******************************************************************************/
module clockgen(input wire CLKIN_IN, 
                output reg CLKFX_OUT, 
                output reg LOCKED);
  
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
module resetgen(input  wire CLK, 
                input  wire RST_X_I, 
                output wire RST_X_O);

  reg [7:0] cnt;
  assign RST_X_O = cnt[7];

  always @(posedge CLK) begin
    if      (!RST_X_I) cnt <= 0;
    else if (~RST_X_O) cnt <= (cnt + 1'b1);
  end
endmodule
/******************************************************************************/

`default_nettype wire
