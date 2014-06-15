/****************************************************************************************/
/* Clock Frequency Definition                                                           */
/* Clock Freq = (System Clock Freq) * (DCM_CLKFX_MULTIPLY) / (DCM_CLKFX_DIVIDE)         */
/****************************************************************************************/
`define SYSTEM_CLOCK_FREQ   100     // Atlys, Nexys4 -> 100 MHz,   VC707 -> 200 MHz
`define DCM_CLKIN_PERIOD    10.000  // Atlys, Nexys4 -> 10.000 ns, VC707 -> 5.000 ns
`define DCM_CLKFX_MULTIPLY  12      // CLKFX_MULTIPLY must be 2~32
`define DCM_CLKFX_DIVIDE    10      // CLKFX_DIVIDE   must be 1~32

`define CLOCK_FREQ  (`SYSTEM_CLOCK_FREQ * `DCM_CLKFX_MULTIPLY / `DCM_CLKFX_DIVIDE)

/****************************************************************************************/
/* UART Definition                                                                      */
/****************************************************************************************/
// !!!!! NOTE (for VC707) !!!!! 
// 1.5 Mbps is available   on VC707 (SERIAL_WCNT = Clock Freq / 1.5)
// 1   Mbps is unavailable on VC707
// 50  Kbps is available   on VC707

`define SERIAL_WCNT  `CLOCK_FREQ  // 1M baud UART wait count (SERIAL_WCNT = Clock Freq / 1)
/****************************************************************************************/
`define SS_SER_WAIT  'd0       // do not modify this. RS232C deserializer, State WAIT
`define SS_SER_RCV0  'd1       // do not modify this. RS232C deserializer, State Receive0
`define SS_SER_DONE  'd9       // do not modify this. RS232C deserializer, State DONE
/****************************************************************************************/

/****************************************************************************************/
