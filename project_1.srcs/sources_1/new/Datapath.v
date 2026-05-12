`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/16/2026 09:52:03 AM
// Design Name: 
// Module Name: Datapath
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


module Datapath(
    input wire clk,
    input wire reset,
    
    // Control store LD signals
    input wire LD_MAR,
    input wire LD_MDR,
    input wire LD_IR,
    input wire LD_BEN,
    input wire LD_REG,
    input wire LD_CC,
    input wire LD_PC,
    input wire LD_VEC,
    input wire LD_EXCV,
    input wire LD_PRIV,
    input wire LD_USP,
    input wire LD_SSP,
    input wire LD_VA,
    input wire LD_PFN,
    input wire LD_PTE,
    input wire LD_SAVED_PSR,
    
    // Exception check flag
    input wire CHECK_PTE, // for page fault check
    input wire CHECK_UNALIGNED,
    
    // Control store MUX select signals
    input wire [1:0] PTEMUX,
    input wire [1:0] INMARMUX,
    input wire       R6MUX,
    input wire       R6INMUX,
    input wire       VECMUX,
    input wire       SPMUX,
    input wire       PRIMUX,
    input wire       PSRMUX,
    input wire [1:0] PCMUX,
    input wire [1:0] DRMUX,
    input wire [1:0] SR1MUX,
    input wire       ADDR1MUX,
    input wire [1:0] ADDR2MUX,
    input wire       MARMUX,
    input wire [1:0] ALUK,
    input wire       MIO_EN,
    input wire       R_W,
    input wire       DATA_SIZE,
    input wire       LSHF1,
    
    // MDRMUX select signal
    input wire       MDRMUX,
    
    // Control store GATE signals
    input wire GATE_PC,
    input wire GATE_MDR,
    input wire GATE_ALU,
    input wire GATE_MARMUX,
    input wire GATE_SHF,
    input wire GATE_PCSUB,
    input wire GATE_PSR,
    input wire GATE_R6,
    input wire GATE_VEC,
    input wire GATE_SP,
    input wire GATE_PTBR,
    input wire GATE_VA,
    input wire GATE_PTE,
    input wire GATE_SAVED_PSR,
    
    // Data coming from Memory
    input wire [15:0] IN_DATA,
    
    // INTV vector has to be external 
    input wire [7:0] INTV,
    
    // Out signals => to be assigned to BUS at top module(CPU) if GATE signal is high
//    output wire [15:0] PC_OUT,
    output wire [15:0] MDR_OUT,
    output wire [15:0] MAR_OUT,
    output wire [15:0] IR_OUT,
    output wire        BEN_OUT,
  
    output wire EXC_flag
    
);
    // BUS
    wire [15:0] BUS;
    // place holder wire
    wire [15:0] adder_out; 
    wire [15:0] ir_out;
    
    wire SR2MUX;
    
    // for Register File module instatiation and SR1,2 and DRMUX logic
    wire [2:0] DR;
    wire [2:0] SR1;
    // no need for SR2 since SR2 is default IR[2:0]
    
    reg [15:0] PTBR;
    
    // Registers
    reg [15:0] MAR;
    reg [15:0] MDR;   
    reg [15:0] IR;
    reg        BEN;
    reg [15:0] REG;
    reg [2:0]  CC;
    reg [15:0] PC;
    reg [7:0] VEC;
    reg [7:0]  EXCV;
    reg        PRIV;
    reg [15:0] USP;
    reg [15:0] SSP;
    reg [15:0]  VA;
    reg [4:0]  PFN;
    reg [15:0] PTE;
    reg [15:0] SAVED_PSR;
    
    wire [15:0] next_Reg_R6;
    
    wire [15:0] PC_OUT;
    wire [15:0] MARMUX_OUT;
    wire [15:0] PTE_OUT;
    
    // Instantiate reg file
    wire [15:0] sr1_out;
    wire [15:0] sr2_out;


    Reg_file lc3b_reg_file (
        .clk(clk),
        .reset(reset),
        .LD_REG(LD_REG),
        .DR(DR),
        .SR1(SR1),
        .SR2(IR[2:0]),
        .BUS_IN(next_Reg_R6),
        .SR1_OUT(sr1_out),
        .SR2_OUT(sr2_out)
    );
    
    
    
    // instantiate shifter 
    wire [15:0] shf_out;

    SHF lc3b_shf (
        .IN(sr1_out),
        .AMT(IR[3:0]),
        .SHF_OP(IR[5:4]),
        .OUT(shf_out)
    );
    
    
    
    // instantiate ALU module
    
    wire [15:0] ALU_out;
    wire [15:0] ALU_B;
    
    ALU lc3b_ALU (
        .A(sr1_out),
        .B(ALU_B),
        .ALUK(ALUK),
        .out(ALU_out)
    );
    
    
    // USP logic
    always @(posedge clk) begin
        if (reset)
            USP <= 16'h0000;
        else if (LD_USP)
            USP <= sr1_out;
    end
    
    
    
    // SSP logic
    always @(posedge clk) begin
        if (reset)
            SSP <= 16'h0000;
        else if (LD_SSP)
            SSP <= sr1_out;
    end
    
    
    
    // IR logic
    always @(posedge clk) begin
        if (reset)
            IR <= 16'h0000;
        else if (LD_IR)
            IR <= BUS;
    end
    
    assign IR_OUT = IR;
    
    
    // VA logic
    always @(posedge clk) begin
        if (reset)
            VA <= 16'h0000;
         else if (LD_VA)
            VA <= BUS;
    end
    
    
    
    // PFN logic
    always @(posedge clk) begin
        if (reset)
            PFN <= 5'b00000;
        else if (LD_PFN)
            PFN <= BUS[13:9];
    end
    
    
    
    // PTEMUX logic
    wire [15:0] PTE_R   = PTE | 4'h0001;
    wire [15:0] PTE_R_M = PTE | 4'h0003;
    wire [15:0] next_pte;
    
    assign next_pte = (PTEMUX == 2'b00) ? BUS :
                      (PTEMUX == 2'b10) ? PTE_R :
                      (PTEMUX == 2'b01) ? PTE_R_M : 16'h0000;
                     
                     
                      
    // PTE seq update logic
    always @(posedge clk) begin
        if (reset)
            PTE <= 16'h0000;
        else if (LD_PTE)
            PTE <= next_pte;
    end
    // Drive the module output
    assign PTE_OUT = PTE;
    
    
    // PTBR logic, could be hard coded to x1000 but for OS applicability, PTBR should be a var for multiprocessing OS
    always @(posedge clk) begin
        if (reset) begin
            PTBR <= 16'h1000;
        end
    end
    
    // INMARMUX logic
    wire [15:0] PTBR_LSHF1_adder = PTBR + {7'b0000000, BUS[15:9], 1'b0};
    wire [15:0] logic_block = {2'b00, PFN, VA[8:0]};
    wire [15:0] next_mar;
    
    assign next_mar = (INMARMUX == 2'b00) ? BUS :
                      (INMARMUX == 2'b01) ? PTBR_LSHF1_adder :
                      (INMARMUX == 2'b10) ? logic_block : 16'h0000;
    
    // MAR seq update logic 
    always @(posedge clk) begin
        if (reset) 
            MAR <= 16'h0000;
        else if (LD_MAR)
            MAR <= next_mar;
    end
    
    assign MAR_OUT = MAR; // memory module needs to know value of MAR, this is so that Datapath.v can broadcast that to Mem.v
    
    
    
    // R6MUX logic
    wire [15:0] R6_plus_2 = sr1_out + 2;
    wire [15:0] R6_sub_2  = sr1_out - 2;
    wire [15:0] next_R6;
    
    assign next_R6 = (R6MUX == 1'b0) ? R6_sub_2 : R6_plus_2;
    
    
    
    // R6INMUX logic
    //wire [15:0] next_Reg_R6;  // output to register file for the R6INMUX
    assign next_Reg_R6 = (R6INMUX == 1'b0) ? BUS : next_R6;
    
    
    
    // VECMUX logic
    wire [7:0] next_vector;
    assign next_vector = (VECMUX == 1'b1) ? INTV : EXCV;
    
    always @(posedge clk) begin
        if (reset) 
            VEC <= 8'h00;
        else if (LD_VEC)
            VEC <= next_vector;
    end
    
    wire [15:0] vector_address;
    
    assign vector_address = {7'b0000001, VEC, 1'b0};
    
    
    
    // SPMUX logic
    wire [15:0] next_sp;
    assign next_sp = (SPMUX == 1'b0) ? USP : SSP;
    
    
    
    // PRIMUX logic
    wire next_priv;
    assign next_priv = (PRIMUX == 1'b0) ? 1'b0 : BUS[15];
    
    always @(posedge clk) begin
        if (reset) 
            //PRIV <= 1'b0;
            PRIV <= 1'b1; // to test protection;
        else if (LD_PRIV)
            PRIV <= next_priv;
    end
    

    
    
    // PC + PCSUB logic
    wire [15:0] pc_plus_2 = PC + 16'd2;
    wire [15:0] next_pc;
    
    assign next_pc = (PCMUX == 2'b00) ? pc_plus_2 :
                     (PCMUX == 2'b01) ? BUS :
                     (PCMUX == 2'b10) ? adder_out : 16'h0000;
                     
    // PC seq update logic
    always @(posedge clk) begin
        if (reset)
            PC <= 16'h3000;
        else if (LD_PC)
            PC <= next_pc;
    end
    
    // Drive the module output
    assign PC_OUT = PC;
    
    wire [15:0] PCSUB_OUT;
    assign PCSUB_OUT = PC - 2;
    
    
    
    
    // DRMUX logic  --- Need to fix before use
    assign DR = (DRMUX == 2'b00) ? IR[11:9] :               // IR[11:9]
                (DRMUX == 2'b01) ? 3'b111 :                 // R7
                (DRMUX == 2'b10) ? 3'b110 : 3'b000;         // R6
    
    
    
    // SR1MUX logic -- same as DRMUX, will write after fixing DRMUX
    assign SR1 = (SR1MUX == 2'b00) ? IR[11:9] :             // IR[11:9]
                 (SR1MUX == 2'b01) ? IR[8:6] :              // IR[8:6]
                 (SR1MUX == 2'b10) ? 3'b110 : 3'b000;       // R6
    
    
    
        
    // SR2MUX logic
    assign SR2MUX = IR[5]; // IR[5] selects between SR2 and imm5 for ADD and AND instructions.
    
    wire [15:0] sext_4_0 = { {11{IR[4]}}, IR[4:0] } ;    // need to add SEXT logic
    
    assign ALU_B = (SR2MUX == 1'b1) ? sext_4_0 : sr2_out;
    
    
    
    // ADDR1MUX logic
    wire [15:0] next_addr1;
    assign next_addr1 = (ADDR1MUX == 1'b1) ? sr1_out : PC;
    
    
    
    
    // ADDR2MUX logic
    wire [15:0] sext_10_0 = { {5{IR[10]}}, IR[10:0] };
    wire [15:0] sext_8_0 = { {7{IR[8]}}, IR[8:0] };
    wire [15:0] sext_5_0 = { {10{IR[5]}}, IR[5:0] };
    
    wire [15:0] next_addr2;
    assign next_addr2 = (ADDR2MUX == 2'b11) ? sext_10_0 :
                        (ADDR2MUX == 2'b10) ? sext_8_0 :
                        (ADDR2MUX == 2'b01) ? sext_5_0 : 16'h0000;
                        
    // missing adder_out logic
    assign adder_out = (next_addr2 << 1) + next_addr1;
    
    
    
    // MARMUX logic
    wire [15:0] zext_ir = {7'b0000000, ir_out[7:0], 1'b0};
    wire [15:0] next_marmux_out;
    
    assign next_marmux_out = (MARMUX == 1'b0) ? zext_ir : adder_out;
    
    // Drive the module output
    assign MARMUX_OUT = next_marmux_out;
    
    
    
    
    // EXC logic => NEED separate logic to generate EXC logic 
    
//    wire [4:0] protection_check = {MAR[15:12], PRIV};
//    wire protection_exc;
//    assign protection_exc = (protection_check == 5'b00001) ||
//                            (protection_check == 5'b00011) ||
//                            (protection_check == 5'b00101);
    // new protection logic 
    wire protection_exc;
    assign protection_exc = (CHECK_PTE == 1'b1) && (MDR[3] == 1'b0) && (PRIV == 1'b1);
    
    wire unknown_exc;
    assign unknown_exc = (IR[15:12] == 4'b1010) ||
                         (IR[15:12] == 4'b1011);
                         
    wire page_fault_exc;
    assign page_fault_exc = (CHECK_PTE == 1'b1) && (MDR[2] == 1'b0);
    
    wire unaligned_exc;
    wire is_word_instr = ((IR[15:12] == 4'b0010) || (IR[15:12] == 4'b0011));
    assign unaligned_exc = (CHECK_UNALIGNED == 1'b1) && !is_word_instr && (MAR[0] == 1'b1);
    
    assign EXC_flag = page_fault_exc || unaligned_exc || unknown_exc || protection_exc;
    
    wire EXC0;
    wire EXC1;
    wire EXC2;
    
    assign EXC0 = protection_exc || unknown_exc;
    assign EXC1 = page_fault_exc || protection_exc;
    assign EXC2 = unaligned_exc;
    
    wire [2:0] EXC_select;
    assign EXC_select = {EXC2, EXC1, EXC0};
    
    // EXCMUX logic
    wire [7:0] next_excv;
    assign next_excv = (EXC_select == 3'b001) ? 8'h05 :
                       (EXC_select == 3'b010) ? 8'h02 :
                       (EXC_select == 3'b011) ? 8'h04 :
                       (EXC_select == 3'b100) ? 8'h03 : 8'h00;
                       
    always @(posedge clk) begin
        if (reset) 
             EXCV <= 8'h00;
        else if (LD_EXCV)
             EXCV <= next_excv;
    end
    
    
    
    // CC module
    wire calc_N = BUS[15];
    wire calc_Z = (BUS == 16'h0000);
    wire calc_P = (~BUS[15]) && (BUS != 16'h0000);
    
    wire [2:0] calculated_nzp = {calc_N, calc_Z, calc_P};
    
    wire [2:0] psrmux_out;
    assign psrmux_out = (PSRMUX == 1'b1) ? BUS[2:0] : calculated_nzp;
    
    always @(posedge clk) begin
        if (reset) 
            CC <= 3'b000;
        else if (LD_CC)
            CC <= psrmux_out;
    end
    
    
    // PSR adder logic - to produce new PSR
    wire [15:0] psr_new;
    assign psr_new = {PRIV<<15, CC};
    
    // SAVED_PSR logic
    wire [15:0] saved_psr_out;
    
    always @(posedge clk) begin
        if (reset)
            SAVED_PSR <= 16'h0000;
        else if (LD_SAVED_PSR)
            SAVED_PSR <= BUS;
    end
    
    
    
    
    // MDR logic
    
    // LOGIC block feeding MDR preMUX to handle STB logic
    wire [15:0] store_align_out;
    
    assign store_align_out = (DATA_SIZE == 1'b0) ? BUS : {BUS[7:0], BUS[7:0]};
    
    // MDR-preMUX logic
    wire [15:0] INMUX_out;       // data from memory, to be written in Memory.v
    
    assign INMUX_out = IN_DATA;
    
    wire [15:0] MDR_preMUX_out;
    
    assign MDR_preMUX_out = (MIO_EN == 1'b1) ? INMUX_out : store_align_out;
    
    // MDRMUX logic
    wire [15:0] MDRMUX_out;
    
    assign MDRMUX_out = (MDRMUX == 1'b1) ? SAVED_PSR : MDR_preMUX_out;
    
    always @(posedge clk) begin
        if (reset)
            MDR <= 16'h0000;
        else if (LD_MDR)
            MDR <= MDRMUX_out;
    end
    
    // Load Sign Extension LOGIC block
    wire [7:0] selected_byte;
    wire [15:0] sign_extended_byte;
    wire [15:0] gate_mdr_data;
    
    assign selected_byte = (MAR[0] == 1'b1) ? MDR[15:8] : MDR[7:0]; // pick the correct byte based on the address
    
    assign sign_extended_byte = {{8{selected_byte[7]}}, selected_byte}; // sign extend the byte 
    
    assign gate_mdr_data = (DATA_SIZE == 1'b0) ? MDR : sign_extended_byte; // pick between Word or Byte based on DATA.SIZE
    
    assign MDR_OUT = MDR;
    
    
    
    // BUS logic
    
    assign BUS = (GATE_PC) ? PC_OUT :
                 (GATE_MDR) ? gate_mdr_data :
                 (GATE_ALU) ? ALU_out :
                 (GATE_MARMUX) ? MARMUX_OUT : 
                 (GATE_PCSUB) ? PCSUB_OUT :
                 (GATE_SHF) ? shf_out :
                 (GATE_PSR) ? psr_new :
                 (GATE_R6) ? next_R6 :
                 (GATE_VEC) ? vector_address : 
                 (GATE_SP) ? next_sp :
                 (GATE_PTE) ? PTE_OUT :
                 (GATE_VA) ? VA :
                 (GATE_SAVED_PSR) ? SAVED_PSR : 16'h0000;
                 
    
    
    // BEN logic
    wire BEN_logic;
    
    assign BEN_logic = (IR[11] & CC[2]) | (IR[10] & CC[1]) | (IR[9] & CC[0]);
    
    always @(posedge clk) begin
        if (reset) 
            BEN <= 1'b0;
        else if (LD_BEN)
            BEN <= BEN_logic;
    end
    
    assign BEN_OUT = BEN;
                 
endmodule
