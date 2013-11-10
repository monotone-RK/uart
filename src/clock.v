`default_nettype none
/******************************************************************************************/
/* Clock & Reset Generator                                                                */
/******************************************************************************************/
module CLKGEN(CLK_I, RST_X_I, CLK_O, RST_X_O);
  input CLK_I, RST_X_I;
  output CLK_O, RST_X_O;

  wire LOCKED;
  clockgen clkgen(CLK_I, CLK_O, LOCKED);
  resetgen rstgen(CLK_O, (RST_X_I & LOCKED), RST_X_O);
endmodule

`define DCM_CLKFX_MULTIPLY  12  // you can modify this value, (100MHz / 10) * 12 = 120MHz
`define DCM_CLKFX_DIVIDE    10  // CLKFX_DIVIDE must be 1~32,CLKFX_MULTIPLY must be 2~32
/******************************************************************************************/
/* Clock Generator : 100MHz input clock -> output clock                                   */
/* Note : this module uses DCM_SP just for Xilinx FPGA                                    */
/******************************************************************************************/
module clockgen(CLK_IN, CLK_OUT, LOCKED);
  input  CLK_IN;
  output CLK_OUT, LOCKED;

  wire   CLK_OBUF, CLK_IBUF, CLK0, CLK0_OUT;

  BUFG   obuf (.I(CLK_OBUF), .O(CLK_OUT));
  BUFG   fbuf (.I(CLK0),     .O(CLK0_OUT));
  IBUFG  ibuf (.I(CLK_IN),   .O(CLK_IBUF));

  DCM_SP dcm (.CLKIN(CLK_IBUF), .CLKFX(CLK_OBUF), .CLK0(CLK0), .CLKFB(CLK0_OUT), 
              .LOCKED(LOCKED), .RST(1'b0), .DSSEN(1'b0), .PSCLK(1'b0), 
              .PSEN(1'b0), .PSINCDEC(1'b0));
  defparam dcm.CLKFX_DIVIDE   = `DCM_CLKFX_DIVIDE;
  defparam dcm.CLKFX_MULTIPLY = `DCM_CLKFX_MULTIPLY;
  defparam dcm.CLKIN_PERIOD   = 10.000; // 100MHz input clock
endmodule

/******************************************************************************************/
/* Reset Generator :  generate about 100 cycle reset signal                               */
/******************************************************************************************/
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
/******************************************************************************************/
`default_nettype wire
