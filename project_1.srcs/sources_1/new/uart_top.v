`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/04/2026 06:27:18 PM
// Design Name: 
// Module Name: uart_top
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


module uart_top(
    input wire clk,
    input wire reset,
    
    // Mem wires
    input wire MIO_EN,
    input wire R_W,
    input wire [15:0] MEM_ADDR,
    input wire [15:0] OUT_DATA,
    
    output reg [15:0] IN_DATA,
    output wire MEM_READY,
    
    // UART IO
    input wire rx,
    output wire tx
    );
    
    wire tx_ready;
    wire rx_valid_pulse;
    wire [7:0] rx_data;
    
    // Check if we talking to the UART
    wire is_uart_addr = (MEM_ADDR == 16'hFE04) || (MEM_ADDR == 16'hFE06);
    wire is_uart_en = MIO_EN & is_uart_addr;
    
    assign MEM_READY = is_uart_en;
    
    // Write logic 
    wire write_udr = is_uart_en & R_W & (MEM_ADDR == 16'hFE04);
    reg prev_write_udr;
    wire tx_start_pulse = write_udr & ~prev_write_udr; // 1-cycle edge detector
    
    // Read logic (RX -> CPU)
    reg rx_has_data;
    wire read_udr = is_uart_en & ~R_W & (MEM_ADDR == 16'hFE04);

    always @(posedge clk) begin
        if (reset) begin
            prev_write_udr <= 1'b0;
            rx_has_data <= 1'b0;
        end else begin
            prev_write_udr <= write_udr;
            
            // Set flag when RX finishes receiving a byte
            if (rx_valid_pulse) begin
                rx_has_data <= 1'b1;
            end 
            // Clear flag when CPU reads the data register
            else if (read_udr) begin
                rx_has_data <= 1'b0;
            end
        end
    end
    
    always @(*) begin
        if (is_uart_en && ~R_W) begin
            if (MEM_ADDR == 16'hFE04) begin
                // Read Data Register (Zero extend the 8bit data)
                IN_DATA = {8'h00, rx_data};
            end else if (MEM_ADDR == 16'hFE06) begin
                // Read Status Register: [15] = TX Ready, [14] = RX Has Data
                IN_DATA = {tx_ready, rx_has_data, 14'h0000};
            end else begin
                IN_DATA = 16'h0000;
            end
        end else begin
            IN_DATA = 16'h0000;
        end
    end
    
    
    uart_tx Transmitter (
        .clk(clk),
        .reset(reset),
        .tx_start(tx_start_pulse),
        .tx_data(OUT_DATA[7:0]),
        .tx(tx),
        .tx_ready(tx_ready)
    );
    
    uart_rx Receiver (
        .clk(clk),
        .reset(reset),
        .rx(rx),
        .rx_data(rx_data),
        .rx_ready(rx_valid_pulse)
    );
    
    
endmodule
