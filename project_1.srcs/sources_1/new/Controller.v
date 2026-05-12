`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Khanh Bui
// 
// Create Date: 04/13/2026 09:29:14 AM
// Design Name: 
// Module Name: Controller
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


module Controller(
    input wire clk,
    input wire reset,
    input wire [15:0] IR,
    input wire BEN,
    input wire R,
    
    input wire INT,
    input wire EXC_flag,
    
    //LD signals
    output reg LD_MAR,
    output reg LD_MDR,
    output reg LD_IR,
    output reg LD_BEN,
    output reg LD_REG,
    output reg LD_CC,
    output reg LD_PC,
    output reg LD_VEC,
    output reg LD_EXCV,
    output reg LD_PRIV,
    output reg LD_USP,
    output reg LD_SSP,
    output reg LD_VA,
    output reg LD_PFN,
    output reg LD_PTE,
    output reg LD_SAVED_PSR, // new
    output reg LD_RET_TRANS, // new 
    
    // Exception check signals
    output reg CHECK_UNALIGNED, // new
    output reg CHECK_PTE, // new    
    //Gate signals
    output reg GATE_PC,
    output reg GATE_MDR,
    output reg GATE_ALU,
    output reg GATE_MARMUX,
    output reg GATE_SHF,
    output reg GATE_PCSUB,
    output reg GATE_PSR,
    output reg GATE_R6,
    output reg GATE_VEC,
    output reg GATE_SP,
    output reg GATE_PTBR,
    output reg GATE_VA,
    output reg GATE_PTE,
    output reg GATE_SAVED_PSR,
    
    // Multiplexer signals
    output reg [1:0] PTEMUX,
    output reg [1:0] INMARMUX,
    output reg R6MUX,
    output reg R6INMUX,
    output reg VECMUX,
    output reg SPMUX,
    output reg PRIMUX,
    output reg PSRMUX,
    output reg [1:0] PCMUX,
    output reg [1:0] DRMUX,
    output reg [1:0] SR1MUX,
    output reg ADDR1MUX,
    output reg [1:0] ADDR2MUX,
    output reg MARMUX,
    output reg [1:0] ALUK,
    output reg MDRMUX, // new 
    
    // Memory control signals
    output reg MIO_EN,
    output reg R_W,
    output reg DATA_SIZE,
    output reg LSHF1
);

    // 6-bit State Registers
    
    reg [5:0] current_state;
    reg [5:0] next_state;
    
    // RET-TRANS latches to hold the next state after address translation.
    reg [5:0] RET_ADDR;
    reg [5:0] RET_TRANS;
    
    reg [15:0] PSR;
    
    always @(posedge clk) begin
        if(reset) begin
            current_state <= 6'd18;   //reset to state 18
            RET_ADDR <= 6'd0;
        end else begin
            current_state <= next_state;
            if (LD_RET_TRANS) begin
                RET_ADDR <= RET_TRANS;
            end
        end
    end
    
    
    always @(*) begin
        //LD signals
        LD_MAR = 1'b0;
        LD_MDR = 1'b0;
        LD_IR = 1'b0;
        LD_BEN = 1'b0;
        LD_REG = 1'b0;
        LD_CC = 1'b0;
        LD_PC = 1'b0;
        LD_VEC = 1'b0;
        LD_EXCV = 1'b0;
        LD_PRIV = 1'b0;
        LD_USP = 1'b0;
        LD_SSP = 1'b0;
        LD_VA = 1'b0;
        LD_PFN = 1'b0;
        LD_PTE = 1'b0;
        LD_SAVED_PSR = 1'b0;
        LD_RET_TRANS = 1'b0;
        
        // Exception check
        CHECK_UNALIGNED = 1'b0;
        CHECK_PTE = 1'b0;
        
        //Gate signals
        GATE_PC = 1'b0;
        GATE_MDR = 1'b0;
        GATE_ALU = 1'b0;
        GATE_MARMUX = 1'b0;
        GATE_SHF = 1'b0;
        GATE_PCSUB = 1'b0;
        GATE_PSR = 1'b0;
        GATE_R6 = 1'b0;
        GATE_VEC = 1'b0;
        GATE_SP = 1'b0;
        GATE_PTBR = 1'b0;
        GATE_VA = 1'b0;
        GATE_PTE = 1'b0;
        GATE_SAVED_PSR = 1'b0;
        
        // Multiplexer signals
        PTEMUX = 2'b00;
        INMARMUX = 2'b00;
        R6MUX = 1'b0;
        R6INMUX = 1'b0;
        VECMUX = 1'b0;
        SPMUX = 1'b0;
        PRIMUX = 1'b0;
        PSRMUX = 1'b0;
        PCMUX = 2'b00;
        DRMUX = 2'b00;
        SR1MUX = 2'b00;
        ADDR1MUX = 1'b0;
        ADDR2MUX = 2'b00;
        MARMUX = 1'b0;
        ALUK = 2'b00;
        MDRMUX = 1'b0;
        
        MIO_EN = 1'b0;
        R_W = 1'b0;
        DATA_SIZE = 1'b0;
        LSHF1 = 1'b0;
        
        next_state = current_state;
        RET_TRANS = 6'd0;
    
    
        case(current_state)
            6'd0: begin         // BR
                if (BEN == 1'b1) begin 
                    next_state = 6'd22;
                end else begin
                    next_state = 6'd18;
                end
            end
            
            6'd1: begin         // ADD
                LD_REG = 1'b1;
                LD_CC = 1'b1;
                GATE_ALU = 1'b1;
                SR1MUX = 2'b01;
                
                next_state = 6'd18;
            end
            
            6'd2: begin         // LDB
                LD_MAR = 1'b1;
                LD_VA = 1'b1;
                GATE_MARMUX = 1'b1;
                SR1MUX = 2'b01;
                ADDR1MUX = 1'b1;
                ADDR2MUX = 2'b01;
                MARMUX = 1'b1;
                
                LD_RET_TRANS = 1'b1;
                RET_TRANS = 6'd29;
                next_state = 6'd34;
               
            end
            
            6'd3: begin         // STB
                LD_MAR = 1'b1;
                LD_VA = 1'b1;
                GATE_MARMUX = 1'b1;
                SR1MUX = 2'b01;
                ADDR1MUX = 1'b1;
                ADDR2MUX = 2'b01;
                MARMUX = 1'b1;
                
                LD_RET_TRANS = 1'b1;
                RET_TRANS = 6'd24;
                next_state = 6'd36;
            end
            
            6'd4: begin         // JSR
                if (IR[11] == 1'b1) begin
                    next_state = 6'd21;
                end else begin
                    next_state = 6'd20;
                end
            end
            
            6'd5: begin          // ADD
                LD_REG = 1'b1;
                LD_CC = 1'b1;
                GATE_ALU = 1'b1;
                SR1MUX = 2'b01;
                ALUK = 2'b01;
                
                next_state = 6'd18;
            end
            
            6'd6: begin             // LDW
                LD_MAR = 1'b1;
                LD_VA = 1'b1;
                GATE_MARMUX = 1'b1;
                SR1MUX = 2'b01;
                ADDR1MUX = 1'b1;
                ADDR2MUX = 2'b01;
                MARMUX = 1'b1;
                LSHF1 = 1'b1;
                
                LD_RET_TRANS = 1'b1;
                RET_TRANS = 6'd25;
                //next_state = 6'd34;  //comment to test HW, bypassing VA translation
                next_state = 6'd25;     //to test HW, bypassing VA translation
            end
            
            6'd7: begin             // STW
                LD_MAR = 1'b1;
                LD_VA = 1'b1;
                GATE_MARMUX = 1'b1;
                SR1MUX = 2'b01;
                ADDR1MUX = 1'b1;
                ADDR2MUX = 2'b01;
                MARMUX = 1'b1;
                LSHF1 = 1'b1;
                
                LD_RET_TRANS = 1'b1;
                RET_TRANS = 6'd23;
                //next_state = 6'd36;   //comment to test HW, bypassing VA translation
                next_state = 6'd23;     // to test HW, bypassing VA translation
            end
            
            6'd8: begin             // RTI
                LD_MAR = 1'b1;
                LD_VA = 1'b1;
                GATE_ALU = 1'b1;
                SR1MUX = 2'b10;
                ALUK = 2'b11;
                
                LD_RET_TRANS = 1'b1;
                RET_TRANS = 6'd60;
                next_state = 6'd34;
            end
            
            6'd9: begin             // XOR
                LD_REG = 1'b1;
                LD_CC = 1'b1;
                GATE_ALU = 1'b1;
                SR1MUX = 2'b01;
                ALUK = 2'b10;    
                  
                next_state = 6'd18;     
            end
            
            6'd10: begin            
                LD_MDR = 1'b1;
                LD_VEC = 1'b1;
                LD_PRIV = 1'b1;
                GATE_PSR = 1'b1;
                DATA_SIZE = 1'b1;
                
                if (PSR[15] == 1'b1) begin
                    next_state = 6'd46;
                end else begin
                    next_state = 6'd38;
                end
            end
            
             6'd11: begin
                LD_MDR = 1'b1;
                LD_VEC = 1'b1;
                LD_PRIV = 1'b1;
                GATE_PSR = 1'b1;
                DATA_SIZE = 1'b1;
                
                if (PSR[15] == 1'b1) begin
                    next_state = 6'd46;
                end else begin
                    next_state = 6'd38;
                end
            end
            
            6'd12: begin
                LD_PC = 1'b1;
                PCMUX = 2'b10;
                SR1MUX = 2'b01;
                ADDR1MUX = 1'b1;
                
                next_state = 6'd18;
            end
            
            6'd13: begin
                LD_REG = 1'b1;
                LD_CC = 1'b1;
                GATE_SHF = 1'b1;
                SR1MUX = 2'b01;
                
                next_state = 6'd18;
            end
            
            6'd14: begin
                LD_REG = 1'b1;
                GATE_MARMUX = 1'b1;
                ADDR2MUX = 2'b10;
                MARMUX = 1'b1;
                LSHF1 = 1'b1;
                
                next_state = 6'd18;
            end
            
            6'd15: begin
                LD_MAR = 1'b1;
                GATE_MARMUX = 1'b1;
                
                LD_RET_TRANS = 1'b1; //RET_TRANS?
                next_state = 6'd28;
            end
            
            6'd16: begin
                MIO_EN = 1'b1;
                R_W = 1'b1;
                //DATA_SIZE = 1'b1;
                
                if (R == 1'b1) begin
                    next_state = 6'd18;
                end else begin
                    next_state = 6'd16;
                end
            end
            
            6'd17: begin
                MIO_EN = 1'b1;
                R_W = 1'b1;
                
                if (R == 1'b1) begin
                    next_state = 6'd19;
                end else begin
                    next_state = 6'd17;
                end
            end
            
            6'd18: begin
                LD_MAR = 1'b1;
                LD_PC = 1'b1;
                LD_VA = 1'b1;
                GATE_PC = 1'b1;
                
                LD_RET_TRANS = 1'b1;
                
                if (INT == 1'b1) begin
                    next_state = 6'd53;
                end else begin
                    next_state = 6'd37;
                end
            end
            
             6'd19: begin
                LD_MAR = 1'b1;
                LD_PC = 1'b1;
                LD_VA = 1'b1;
                GATE_PC = 1'b1;
                
                LD_RET_TRANS = 1'b1;
                
                if (INT == 1'b1) begin
                    next_state = 6'd53;
                end else begin
                    next_state = 6'd37;
                end
            end
            
             6'd20: begin
                LD_REG = 1'b1;
                LD_PC = 1'b1;
                GATE_PC = 1'b1;
                PCMUX = 2'b10;
                DRMUX = 2'b01;
                SR1MUX = 2'b01;
                ADDR1MUX = 1'b1;
                
                next_state = 6'd18;
            end
            
             6'd21: begin
                LD_REG = 1'b1;
                LD_PC = 1'b1;
                GATE_PC = 1'b1;
                PCMUX = 2'b10;
                DRMUX = 2'b01;
                ADDR2MUX = 2'b11;
                LSHF1 = 1'b1;
                
                next_state = 6'd18;
            end
            
            6'd22: begin
                LD_PC = 1'b1;
                PCMUX = 2'b10;
                ADDR2MUX = 2'b10;
                LSHF1 = 1'b1;
                next_state = 6'd18;
            end
            
            6'd23: begin
                LD_MDR = 1'b1;
                GATE_ALU = 1'b1;
                ALUK = 2'b11;
                //DATA_SIZE = 1'b1;
                
                next_state = 6'd16;
            end
            
            6'd24: begin
                LD_MDR = 1'b1;
                GATE_ALU = 1'b1;
                ALUK = 2'b11;
                
                next_state = 6'd17;
            end
            
            6'd25: begin
                LD_MDR = 1'b1;
                MIO_EN = 1'b1;
                //DATA_SIZE = 1'b1;
                
                if (R == 1'b1) begin
                    next_state = 6'd27;
                end else begin
                    next_state = 6'd25;
                end
            end
            
            6'd26: begin
                LD_REG = 1'b1;
                LD_SSP = 1'b1;
                GATE_SP = 1'b1;
                DRMUX = 2'b10;
                SR1MUX = 2'b10;
                
                next_state = 6'd18;
            end
            
            6'd27: begin
                LD_REG = 1'b1;
                LD_CC = 1'b1;
                GATE_MDR = 1'b1;
                //DATA_SIZE = 1'b1;
                
                next_state = 6'd18;
            end
            
            6'd28: begin
                LD_MDR = 1'b1;
                LD_REG = 1'b1;
                GATE_PC = 1'b1;
                DRMUX = 2'b01;
                MIO_EN = 1'b1;
                //DATA_SIZE = 1'b1;
                
                if (R == 1'b1) begin
                    next_state = 6'd30;
                end else begin
                    next_state = 6'd28;
                end
            end
            
            6'd29: begin
                LD_MDR = 1'b1;
                MIO_EN = 1'b1;
                
                if (R == 1'b1) begin
                    next_state = 6'd31;
                end else begin
                    next_state = 6'd29;
                end
            end
            
            6'd30: begin
                LD_PC = 1'b1;
                GATE_MDR = 1'b1;
                PCMUX = 2'b01;
                //DATA_SIZE = 1'b1;
                
                next_state = 6'd18;
            end
            
            6'd31: begin
                LD_REG = 1'b1;
                LD_CC = 1'b1;
                GATE_MDR = 1'b1;
                
                next_state = 6'd18;
            end
            
            6'd32: begin
                LD_BEN = 1'b1;
                LD_EXCV = 1'b1;
                DATA_SIZE = 1'b1;
                
                next_state = {2'b00, IR[15:12]};
            end
            
             6'd33: begin
                LD_MDR = 1'b1;
                MIO_EN = 1'b1;
                //DATA_SIZE = 1'b1;
                
                if (R == 1'b1) begin
                    next_state = 6'd35;
                end else begin
                    next_state = 6'd33;
                end
            end
            
             6'd34: begin
                LD_MAR = 1'b1;
                LD_EXCV = 1'b1;
                GATE_VA = 1'b1;
                
                CHECK_UNALIGNED = 1'b1;
                
                INMARMUX = 2'b01;
                
                if (EXC_flag == 1'b1) begin
                    next_state = 6'd51;
                end else begin
                    next_state = 6'd52;
                end
            end
            
             6'd35: begin
                LD_IR = 1'b1;
                GATE_MDR = 1'b1;
                //DATA_SIZE = 1'b1;
                next_state = 6'd32;
            end
            
             6'd36: begin
                LD_MAR = 1'b1;
                LD_EXCV = 1'b1;
                GATE_VA = 1'b1;
                
                CHECK_UNALIGNED = 1'b1;
                
                INMARMUX = 2'b01;
                DATA_SIZE = 1'b1;
                
                if (EXC_flag == 1'b1) begin
                    next_state = 6'd51;
                end else begin
                    next_state = 6'd56;
                end
            end
            
             6'd37: begin
                // no need to check for STB/STW anymore so now just goes straight to next state as per state machine
                next_state = 6'd33;
            end
            
             6'd38: begin
                LD_MAR = 1'b1;
                LD_REG = 1'b1;
                LD_VA = 1'b1;
                GATE_R6 = 1'b1;
                R6INMUX = 1'b1;
                DRMUX = 2'b10;
                SR1MUX = 2'b10;
                
                LD_RET_TRANS = 1'b1;
                
                // no need to check for STB/STW anymore so now just goes straight to next state as per state machine
                RET_TRANS = 6'd40;
                next_state = 6'd34; // address translation
            end
            
             6'd39: begin
                LD_MDR = 1'b1;
                GATE_PCSUB = 1'b1;
                //DATA_SIZE = 1'b1;
                
                next_state = 6'd41;
            end
            
             6'd40: begin
                MIO_EN = 1'b1;
                R_W = 1'b1;
                //DATA_SIZE = 1'b1;
                
                if (R == 1'b1) begin
                    next_state = 6'd42;
                end else begin
                    next_state = 6'd40;
                end
            end
            
             6'd41: begin
                MIO_EN = 1'b1;
                R_W = 1'b1;
                //DATA_SIZE = 1'b1;
                
                if (R == 1'b1) begin
                    next_state = 6'd43;
                end else begin
                    next_state = 6'd41;
                end
            end
            
             6'd42: begin
                LD_MAR = 1'b1;
                LD_REG = 1'b1;
                LD_VA = 1'b1;
                GATE_R6 = 1'b1;
                R6INMUX = 1'b1;
                DRMUX = 2'b10;
                SR1MUX = 2'b10;
                
                LD_RET_TRANS = 1'b1;
                RET_TRANS = 6'd39;
                next_state = 6'd34;
            end    
            
             6'd43: begin
                LD_MAR = 1'b1;
                LD_VA = 1'b1;
                GATE_VEC = 1'b1;
                
                LD_RET_TRANS = 1'b1;
                RET_TRANS = 6'd45;
                next_state = 6'd34;        
            end
            
             6'd44: begin
                LD_MAR = 1'b1;
                LD_VA = 1'b1;
                GATE_ALU = 1'b1;
                SR1MUX = 2'b10;
                ALUK = 2'b11;
                
                LD_RET_TRANS = 1'b1;
                RET_TRANS = 6'd48;
                next_state = 6'd34;
            end
            
             6'd45: begin
                LD_MDR = 1'b1;
                MIO_EN = 1'b1;
                //DATA_SIZE = 1'b1;
                
                if (R == 1'b1) begin
                    next_state = 6'd47;
                end else begin
                    next_state = 6'd45;
                end
            end
            
             6'd46: begin
                LD_REG = 1'b1;
                LD_USP = 1'b1;
                GATE_SP = 1'b1;
                SPMUX = 1'b1;
                DRMUX = 2'b10;
                SR1MUX = 2'b10;
                
                next_state = 6'd38;
            end
            
             6'd47: begin
                LD_PC = 1'b1;
                GATE_MDR = 1'b1;
                PCMUX = 2'b01;
                //DATA_SIZE = 1'b1;
                
                next_state = 6'd18;
            end
            
             6'd48: begin
                LD_MDR = 1'b1;
                MIO_EN = 1'b1;
                //DATA_SIZE = 1'b1;
                
                if (R == 1'b1) begin
                    next_state = 6'd50;
                end else begin
                    next_state = 6'd48;
                end
            end
            
             6'd49: begin
                
                if (PSR[15] == 1'b1) begin
                    next_state = 6'd26;
                end else begin
                    next_state = 6'd18;
                end
            end
            
             6'd50: begin
                LD_REG = 1'b1;
                LD_CC = 1'b1;
                LD_PRIV = 1'b1;
                GATE_MDR = 1'b1;
                R6MUX = 1'b1;
                R6INMUX = 1'b1;
                PRIMUX = 1'b1;
                PSRMUX = 1'b1;
                DRMUX = 2'b10;
                SR1MUX = 2'b10;
                //DATA_SIZE = 1'b1;
                
                next_state = 6'd49;
            end
            
             6'd51: begin
                LD_MDR = 1'b1;
                LD_VEC = 1'b1;
                LD_EXCV = 1'b1;
                LD_PRIV = 1'b1;
                
                LD_SAVED_PSR = 1'b1;
                
                GATE_PSR = 1'b1;
                //DATA_SIZE = 1'b1;
                
                if (PSR[15] == 1'b1) begin
                    next_state = 6'd46;
                end else begin
                    next_state = 6'd38;
                end
            end
            
             6'd52: begin
                LD_MDR = 1'b1;
                MIO_EN = 1'b1;
               // DATA_SIZE = 1'b1;
                
                if (R == 1'b1) begin
                    next_state = 6'd54;
                end else begin
                    next_state = 6'd52;
                end
            end
            
            6'd53: begin
                LD_MDR = 1'b1;
                LD_VEC = 1'b1;
                LD_PRIV = 1'b1;
                
                LD_SAVED_PSR = 1'b1;
                
                GATE_PSR = 1'b1;
                VECMUX = 1'b1;
                //DATA_SIZE = 1'b1;
                
                if (PSR[15] == 1'b1) begin
                    next_state = 6'd46;
                end else begin
                    next_state = 6'd38;
                end
            end
            
            6'd54: begin
                LD_PFN = 1'b1;
                LD_PTE = 1'b1;
                GATE_MDR = 1'b1;
                //DATA_SIZE = 1'b1;
                
                LD_EXCV = 1'b1;
                CHECK_PTE = 1'b1;
                
                if (EXC_flag == 1'b1) begin
                    next_state = 6'd51;
                end else begin
                    next_state = 6'd55;
                end
            end
            
            6'd55: begin
            
                LD_PTE = 1'b1;
                PTEMUX = 2'b10;
                
                next_state = 6'd59;
            end
            
            6'd56: begin
                LD_MDR = 1'b1;
                MIO_EN = 1'b1;
                //DATA_SIZE = 1'b1;
                
                if (R == 1'b1) begin
                    next_state = 6'd58;
                end else begin
                    next_state = 6'd56;
                end
            end
            
            6'd57: begin
                //LD_EXCV = 1'b1;
                LD_PTE = 1'b1;
                PTEMUX = 2'b01;
                
                next_state = 6'd59;
            end
            
            6'd58: begin
             
                LD_PFN = 1'b1;
                LD_PTE = 1'b1;
                GATE_MDR = 1'b1;
                //DATA_SIZE = 1'b1;
                
                LD_EXCV = 1'b1;
                CHECK_PTE = 1'b1;
                
                if (EXC_flag == 1'b1) begin
                    next_state = 6'd51;
                end else begin
                    next_state = 6'd57;
                end
            end
            
            6'd59: begin
                LD_MDR = 1'b1;
                GATE_PTE = 1'b1;
               // DATA_SIZE = 1'b1;
                
                next_state = 6'd61;
            end
            
            6'd60: begin
                LD_MDR = 1'b1;
                MIO_EN = 1'b1;
                //DATA_SIZE = 1'b1;
                
                if (R == 1'b1) begin
                    next_state = 6'd62;
                end else begin
                    next_state = 6'd60;
                end
            end
            
            6'd61: begin
                MIO_EN = 1'b1;
                R_W = 1'b1;
                //DATA_SIZE = 1'b1;
                
                if (R == 1'b1) begin
                    next_state = 6'd63;
                end else begin
                    next_state = 6'd61;
                end
            end
            
            6'd62: begin
                LD_REG = 1'b1;
                LD_PC = 1'b1;
                GATE_MDR = 1'b1;
                R6MUX = 1'b1;
                R6INMUX = 1'b1;
                PCMUX = 2'b01;
                DRMUX = 2'b10;
                SR1MUX = 2'b10;
                //DATA_SIZE = 1'b1;
                
                next_state = 6'd44;
            end
            
            6'd63: begin
                LD_MAR = 1'b1;
                INMARMUX = 2'b10;
                
                // additional logic to handle reload of MDR with PSR 
                GATE_SAVED_PSR = 1'b1;
                LD_MDR = 1'b1;
                MDRMUX = 1'b1;
                next_state = RET_ADDR;
            end
            
        endcase
    end
        
endmodule
