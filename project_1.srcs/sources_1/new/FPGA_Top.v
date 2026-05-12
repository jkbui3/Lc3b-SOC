`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/03/2026 11:31:00 PM
// Design Name: 
// Module Name: FPGA_Top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module FPGA_Top(
    input wire clk_100mhz,
    input  wire reset_btn,     // Pin U18 (Center Button)
    input  wire [15:0] sw,     // Physical Switches
    output wire  [15:0] LED,     // Physical LEDs
    input wire RsRx,
    output wire RsTx
    );
    
    wire clk_95mhz;
    wire locked;
    
    
    clk_wiz_0 clock_generator (
        .clk_in1(clk_100mhz), 
        .clk_out1(clk_95mhz), 
        .reset(reset_btn), 
        .locked(locked)
    );
    
    // Hold CPU in reset until clock is stable or if button is pressed
    wire sys_reset = ~locked | reset_btn;
    
    // BUS signals
    wire [15:0] MEM_ADDR;
    wire [15:0] OUT_DATA;
    wire [15:0] IN_DATA;
    wire MIO_EN;
    wire R_W;
    wire DATA_SIZE;
    wire MEM_READY; 
    
    Top Lc3b_Core (
        .clk(clk_95mhz),
        .reset(sys_reset),
        .INT(1'b0),     // No hardware interrupts yet
        .INTV(8'h00),
        .MEM_ADDR(MEM_ADDR),
        .OUT_DATA(OUT_DATA),
        .IN_DATA(IN_DATA),
        .MIO_EN(MIO_EN),
        .DATA_SIZE(DATA_SIZE),
        .R_W(R_W),
        .MEM_READY(MEM_READY)
    );
   

    // testing 95mhz clock generation
    reg [14:0] cpu_leds; // Internal register for the CPU's LEDs
    
    always @(posedge clk_95mhz) begin
        if (sys_reset) 
            cpu_leds <= 15'h0000;
        else if (MIO_EN && R_W && MEM_ADDR == 16'hFE00) 
            cpu_leds <= OUT_DATA[14:0];    
    end
    
    // LED 15 for debugging 95mhz clk
    assign LED = {locked, cpu_leds};
    

    wire [15:0] ram_data_out;
    wire ram_ready;
    
    wire [15:0] uart_data_out;
    wire uart_ready;
    
    // UART wrapper
    uart_top System_UART (
        .clk(clk_95mhz),
        .reset(sys_reset),
        .MIO_EN(MIO_EN),
        .R_W(R_W),
        .MEM_ADDR(MEM_ADDR),
        .OUT_DATA(OUT_DATA),
        .IN_DATA(uart_data_out),
        .MEM_READY(uart_ready),
        .rx(RsRx),
        .tx(RsTx)
    );

    // The Master Input Multiplexer
    assign IN_DATA = 
        (MIO_EN && !R_W && MEM_ADDR == 16'hFE02) ? sw :
        (MIO_EN && !R_W && (MEM_ADDR == 16'hFE04 || MEM_ADDR == 16'hFE06)) ? uart_data_out :
        ram_data_out;
    
    // The Master Ready Multiplexer
    assign MEM_READY = 
        (MIO_EN && MEM_ADDR == 16'hFE00) ? 1'b1 : // LEDs
        (MIO_EN && MEM_ADDR == 16'hFE02) ? 1'b1 : // Switches
        (MIO_EN && (MEM_ADDR == 16'hFE04 || MEM_ADDR == 16'hFE06)) ? uart_ready : // UART
        ram_ready; // RAM

    // Only allow writes to RAM if address is below xFE00
    wire ram_mio_en = MIO_EN && (MEM_ADDR < 16'hFE00);
    
    // RAM
    Mem Sys_RAM (
        .clk(clk_95mhz),
        .MIO_EN(ram_mio_en),
        .R_W(R_W),
        .DATA_SIZE(DATA_SIZE),
        .MAR(MEM_ADDR),
        .MDR_OUT(OUT_DATA),
        .IN_DATA(ram_data_out),
        .R(ram_ready)
    );
    
    
endmodule
