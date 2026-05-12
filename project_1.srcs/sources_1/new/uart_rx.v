`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/04/2026 06:19:29 PM
// Design Name: 
// Module Name: uart_rx
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


module uart_rx(
    input wire clk,         // The 95MHz system clock
    input wire reset,       // System reset
    input wire rx,        
    
    output reg [7:0] rx_data, // assembled byte
    output reg rx_ready
    );
    
    // receiver needs to sample 16x the sending rate to eliminate noise => 95000000 / (16 x 1152000) = 51.5
    // initiate a 0 to 51 counter
    reg [5:0] oversample_counter;
    wire oversample_tick;
    
    always @(posedge clk) begin
        if (reset) begin
            oversample_counter <= 6'd0;
        end else if (oversample_counter == 6'd51) begin
            oversample_counter <= 6'd0;
        end else begin
            oversample_counter <= oversample_counter + 1;
        end
    end
    
    assign oversample_tick = (oversample_counter == 6'd51);
    
    // state machine
    localparam IDLE  = 2'b00;
    localparam START = 2'b01;
    localparam DATA  = 2'b10;
    localparam STOP  = 2'b11;
    
    reg [1:0] state;
    reg [3:0] tick_count;   // Counts the 16 sub-ticks to find the center
    reg [2:0] bit_idx;      // Which data bit we are receiving (0 to 7)
    reg [7:0] shift_reg;    // Holds the bits as they arrive

    always @(posedge clk) begin
        if (reset) begin
            state <= IDLE;
            rx_ready <= 1'b0;
            tick_count <= 4'd0;
            bit_idx <= 3'd0;
            rx_data <= 8'd0;
            shift_reg <= 8'd0;
        end else begin
            // Default rx_ready to 0. It will only pulse High for 1 cycle when done.
            rx_ready <= 1'b0; 

            if (oversample_tick) begin
                case (state)
                    IDLE: begin
                        if (rx == 1'b0) begin 
                            state <= START;
                            tick_count <= 4'd0;
                        end
                    end
                    
                    START: begin
                        if (tick_count == 4'd7) begin // exact center of the start bit(7 cycles)
                            if (rx == 1'b0) begin     // Verify it's still low (not a noise glitch)
                                state <= DATA;
                                tick_count <= 4'd0;
                                bit_idx <= 3'd0;
                            end else begin
                                state <= IDLE;        // If glitch, go back to sleep
                            end
                        end else begin
                            tick_count <= tick_count + 1;
                        end
                    end
                    
                    DATA: begin
                        if (tick_count == 4'd15) begin // 16 ticks to next center
                            shift_reg <= {rx, shift_reg[7:1]}; 
                            tick_count <= 4'd0;
                            
                            if (bit_idx == 3'd7) begin
                                state <= STOP;
                            end else begin
                                bit_idx <= bit_idx + 1;
                            end
                        end else begin
                            tick_count <= tick_count + 1;
                        end
                    end
                    
                    STOP: begin
                        if (tick_count == 4'd15) begin // Center of the stop bit
                            state <= IDLE;
                            rx_data <= shift_reg;      
                            rx_ready <= 1'b1;          //signal cpu for new data
                        end else begin
                            tick_count <= tick_count + 1;
                        end
                    end
                endcase
            end
        end
    end
    
endmodule
