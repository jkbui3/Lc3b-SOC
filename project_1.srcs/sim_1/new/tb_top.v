`timescale 1ns / 1ps

module tb_top();

    // --- Signal Declarations ---
    reg clk;
    reg reset;
    
    // External Interrupt Signals (No Priority Logic)
    reg INT;
    reg [7:0] INTV;

    // --- CPU Instantiation ---
    Top my_cpu (
        .clk(clk),
        .reset(reset),
        .INT(INT),         // Make sure INT is in Top.v
        .INTV(INTV)        // Make sure INTV is in Top.v
    );

    // --- Clock Generation ---
    always #5 clk = ~clk;

    // --- Simulation Stimulus ---
    initial begin
        clk = 0;
        reset = 1;
        
        // Initialize interrupt signals to 0
        INT = 0;
        INTV = 8'h00;
        
        // Initialize the Supervisor Stack Pointer (R6)
        my_cpu.cpu_datapath.lc3b_reg_file.registers[6] = 16'h3000;

        #20;
        reset = 0;

        // Let the CPU run the ADD loop
        #500;
        
        // FIRE THE INTERRUPT
        INT = 1;
        INTV = 8'h01;     // Send Vector x01
        
        // Hold the signal high so the CPU sees it at the end of the instruction
        #100;
        
        // DROP THE INTERRUPT
        INT = 0;
        INTV = 8'h00;

        // Run long enough to watch the handler execute and RTI back
        #5000; 
        
        $finish; 
    end
endmodule