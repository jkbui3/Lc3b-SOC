`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/04/2026 05:44:19 PM
// Design Name: 
// Module Name: uart_tx
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


module uart_tx(
    input wire clk,     // 95mhz clk
    input wire reset,
    input wire tx_start,
    input wire [7:0] tx_data,
    
    output reg tx,      // wire going to laptop
    output reg tx_ready     // high when idle, low when sending
    );
    
    // baud rate generator, aiming 115200 bits/sec
    // 95000000 / 115200 = 824.5 i.e need counter from 0 to 824 for baud rate clock i.e. 10 bit register(0-1023) for counter
    
    reg [9:0] baud_counter;
    wire baud_tick;
    
    always @(posedge clk) begin
        if (reset) begin
            baud_counter <= 10'd0;
        end else if (tx_start) begin          
            baud_counter <= 10'd0;
        end else if (baud_counter == 10'd824) begin
            baud_counter <= 10'd0;
        end else begin
            baud_counter <= baud_counter + 1;
        end
    end
    
    assign baud_tick = (baud_counter == 10'd824);
    
    // Trasnsmitter state machine 
    // 4 states IDLE START DATA table
    localparam IDLE = 2'b00;
    localparam START = 2'b01;
    localparam DATA = 2'b10;
    localparam STOP = 2'b11;
    
    reg [1:0] state;
    reg [2:0] bit_idx;      // which of the 8 data bits
    reg [7:0] shift_reg;    // shift reg to Receiver
    
    always @(posedge clk) begin
        if (reset) begin
            state <= IDLE;
            tx <= 1'b1;
            tx_ready <= 1'b1;
            bit_idx <= 3'd0;
            shift_reg <= 8'd0;
        end else begin
            case (state)
                IDLE: begin
                    tx <= 1'b1;
                    tx_ready <= 1'b1;
                    if (tx_start) begin
                        shift_reg <= tx_data;
                        tx_ready <= 1'b0;       // signal busy to CPU
                        state <= START;
                        //baud_counter <= 10'd0;      // reset
                    end
                end
                
                START: begin
                    tx <= 1'b0;     // start bit low
                    if (baud_tick) begin
                        state <= DATA;
                        bit_idx <= 3'd0;
                    end
                end
                
                DATA: begin
                    tx <= shift_reg[0];     // output LSB
                    if (baud_tick) begin 
                        shift_reg <= {1'b0, shift_reg[7:1]};    // shift right
                        if (bit_idx == 3'd7) begin
                            state <= STOP;
                        end else begin
                            bit_idx <= bit_idx + 1;
                        end
                    end
                end
                
                STOP: begin
                    tx <= 1'b1;
                    if (baud_tick) begin
                        state <= IDLE;
                    end
                end
           endcase
      end
      
    end
    
    
    
endmodule
