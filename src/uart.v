`default_nettype none

`define SERIAL_WCNT  'd120     // 120MHz/1M baud, parameter for UartRx and UartTx
/******************************************************************************************/
`define SS_SER_WAIT  'd0       // do not modify this. RS232C deserializer, State WAIT
`define SS_SER_RCV0  'd1       // do not modify this. RS232C deserializer, State Receive0
`define SS_SER_DONE  'd9       // do not modify this. RS232C deserializer, State DONE
/******************************************************************************************/
module UartRx(CLK, RST_X, RXD, DATA, EN);
  input          CLK, RST_X, RXD; // clock, reset, RS232C input
  output [7:0]   DATA;            // 8bit output data
  output         EN;              // 8bit output data enable

  reg [7:0]      DATA;
  reg [3:0]      stage; 
  reg [20:0]     cnt;                  // counter to latch D0, D1, ..., D7
  reg [19:0]     cnt_detect_startbit;  // counter to detect the Start Bit
  wire [20:0]    waitcnt;
    
  assign EN = (stage==`SS_SER_DONE);

  assign waitcnt = `SERIAL_WCNT;

  always @(posedge CLK or negedge RST_X) begin
    if (!RST_X) cnt_detect_startbit <= 0;
    else        cnt_detect_startbit <= (RXD) ? 0 : cnt_detect_startbit + 1;
  end
  
  always @(posedge CLK or negedge RST_X) begin
    if(!RST_X) begin
      stage  <= `SS_SER_WAIT;
      cnt    <= 1;
      DATA   <= 0;
    end else if (stage==`SS_SER_WAIT) begin // detect the Start Bit
      stage <= (cnt_detect_startbit==(waitcnt>>1)) ? `SS_SER_RCV0 : stage;
    end else begin
      if (cnt!=waitcnt) cnt <= cnt + 1;
      else begin               // receive 1bit data
        stage  <= (stage==`SS_SER_DONE) ? `SS_SER_WAIT : stage + 1;
        DATA   <= {RXD, DATA[7:1]};
        cnt <= 1;
      end
    end
  end
endmodule

/******************************************************************************************/
module UartTx(CLK, RST_X, DATA, WE, TXD, READY);
  input       CLK, RST_X, WE;
  input [7:0] DATA;
  output reg  TXD, READY;

  reg [8:0]   cmd;
  reg [11:0]  waitnum;
  reg [3:0]   cnt;

  always @(posedge CLK or negedge RST_X) begin
    if(!RST_X) begin
      TXD       <= 1'b1;
      READY     <= 1'b1;
      cmd       <= 9'h1ff;
      waitnum   <= 0;
      cnt       <= 0;
    end else if (READY) begin
      TXD       <= 1'b1;
      waitnum   <= 0;
      if (WE) begin
        READY <= 1'b0;
        cmd   <= {DATA, 1'b0};
        cnt   <= 10;
      end
    end else if (waitnum >= `SERIAL_WCNT) begin
      TXD       <= cmd[0];
      READY     <= (cnt == 1);
      cmd       <= {1'b1, cmd[8:1]};
      waitnum   <= 1;
      cnt       <= cnt - 1;
    end else begin
      waitnum   <= waitnum + 1;
    end
  end
endmodule

