`default_nettype none

module main(input  wire      CLK_IN, 
            input  wire      RST_X_IN, 
            input  wire      RXD, 
            output wire      TXD, 
            output reg [7:0] LED);
    
  wire CLK, RST_X;
  CLKGEN clkgen(CLK_IN, RST_X_IN, CLK, RST_X);
    
  reg        we;
  reg [25:0] cnt;
  always @(posedge CLK or negedge RST_X) begin
    if (!RST_X) cnt <= 0;
    else begin
      cnt <= cnt + 1; 
      we  <= (cnt[25:0] == 0);
    end
  end
    
  wire ready;
  UartTx send(CLK, RST_X, we, 8'h61, TXD, ready);  // send character 'a'
       
  wire [7:0] data;
  wire       en;
  UartRx recv(CLK, RST_X, RXD, data, en);
  always @(posedge CLK) if (en) LED <= data;
  
endmodule
`default_nettype wire
