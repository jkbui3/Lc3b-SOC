`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/22/2026 10:50:10 PM
// Design Name: 
// Module Name: Top
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


module Top(
    input wire clk,
    input wire reset,
    input wire INT,           // Interrupts are external to the system  
    input wire [7:0] INTV,     // same as above
    
    // Exposed memory wires:
    output wire [15:0] MEM_ADDR,   // MAR
    output wire [15:0] OUT_DATA,   // MDR
    input wire [15:0] IN_DATA, // from INMUX
    
    // Mem control signals
    output wire MIO_EN,
    output wire DATA_SIZE,  // 0 = word, 1 = byte
    output wire R_W,
    input wire MEM_READY    // R
    //output wire [15:0] dummy_out 
);

// --- Control Signals (Controller -> Datapath) ---
    wire LD_MAR, LD_MDR, LD_IR, LD_BEN, LD_REG, LD_CC, LD_PC, LD_VEC, LD_EXCV, LD_PRIV, LD_USP, LD_SSP, LD_VA, LD_PFN, LD_PTE, LD_SAVED_PSR;
    wire GATE_PC, GATE_MDR, GATE_ALU, GATE_MARMUX, GATE_SHF, GATE_PCSUB, GATE_PSR, GATE_R6, GATE_VEC, GATE_SP, GATE_PTBR, GATE_VA, GATE_PTE, GATE_SAVED_PSR;
    wire [1:0] PTEMUX;
    wire [1:0] INMARMUX;
    wire       R6MUX;
    wire       R6INMUX;
    wire       VECMUX;
    wire       SPMUX;
    wire       PRIMUX;
    wire       PSRMUX;
    wire [1:0] PCMUX;
    wire [1:0] DRMUX;
    wire [1:0] SR1MUX;
    wire       ADDR1MUX;
    wire [1:0] ADDR2MUX;
    wire       MARMUX;
    wire [1:0] ALUK;
    wire MDRMUX; 

    // --- Status Signals (Datapath -> Controller) ---
    wire [15:0] IR;
   // wire N, Z, P;
    wire BEN;
   // wire ISR_FLAG; 
    wire EXC_flag;

//    // --- Memory Bus ---
//    wire [15:0] MEM_ADDR;   // From Datapath (MAR) -> Memory
//    wire [15:0] OUT_DATA;   // From Datapath (MDR) -> Memory
//    wire [15:0] IN_DATA;    // From Memory -> Datapath (INMUX)
    
//    wire MIO_EN;            // From Controller -> Memory (Chip Enable)
//    wire R_W;               // From Controller -> Memory (Read/Write)
//    wire DATA_SIZE;         // From Controller -> Memory (Word/Byte)
//    wire MEM_READY;         // From Memory -> Controller (Ready bit R)
    
    wire CHECK_UNALIGNED;
    wire CHECK_PTE;
    
//    assign dummy_out = OUT_DATA; 
    
   
    // 1. Controller
    
    Controller cpu_control (
        .clk(clk),
        .reset(reset),
        
        // Status Inputs
        .IR(IR),
        .BEN(BEN),
        .R(MEM_READY),
        
        // Interrupt and Exception flags
        .INT(INT),
        .EXC_flag(EXC_flag),
        
        // Memory Control Outputs
        .MIO_EN(MIO_EN),
        .R_W(R_W),
        .DATA_SIZE(DATA_SIZE),
        
        // EXC check signals
        .CHECK_UNALIGNED(CHECK_UNALIGNED),
        .CHECK_PTE(CHECK_PTE),
        
        .LD_MAR(LD_MAR),
        .LD_MDR(LD_MDR),
        .LD_IR(LD_IR),
        .LD_BEN(LD_BEN),
        .LD_REG(LD_REG),
        .LD_CC(LD_CC),
        .LD_PC(LD_PC),
        .LD_VEC(LD_VEC),
        .LD_EXCV(LD_EXCV),
        .LD_PRIV(LD_PRIV),
        .LD_USP(LD_USP),
        .LD_SSP(LD_SSP),
        .LD_VA(LD_VA),
        .LD_PFN(LD_PFN),
        .LD_PTE(LD_PTE),
        .LD_SAVED_PSR(LD_SAVED_PSR),
        .LD_RET_TRANS(LD_RET_TRANS),
        
        .GATE_PC(GATE_PC),
        .GATE_MDR(GATE_MDR),
        .GATE_ALU(GATE_ALU),
        .GATE_MARMUX(GATE_MARMUX),
        .GATE_SHF(GATE_SHF),
        .GATE_PCSUB(GATE_PCSUB),
        .GATE_PSR(GATE_PSR),
        .GATE_R6(GATE_R6),
        .GATE_VEC(GATE_VEC),
        .GATE_SP(GATE_SP),
        .GATE_PTBR(GATE_PTBR),
        .GATE_VA(GATE_VA),
        .GATE_PTE(GATE_PTE),
        .GATE_SAVED_PSR(GATE_SAVED_PSR),
   
        .PTEMUX(PTEMUX),
        .INMARMUX(INMARMUX),
        .R6MUX(R6MUX),
        .R6INMUX(R6INMUX),
        .VECMUX(VECMUX),
        .SPMUX(SPMUX),
        .PRIMUX(PRIMUX),
        .PSRMUX(PSRMUX),
        .PCMUX(PCMUX),
        .DRMUX(DRMUX),
        .SR1MUX(SR1MUX),
        .ADDR1MUX(ADDR1MUX),
        .ADDR2MUX(ADDR2MUX),
        .MARMUX(MARMUX),
        .ALUK(ALUK),
        .MDRMUX(MDRMUX),
        
        .LSHF1(LSHF1)
        
        
    );

   
    // 2. Datapath
    
    Datapath cpu_datapath (
        .clk(clk),
        .reset(reset),
        
        // Control Inputs from Controller
        .LD_MAR(LD_MAR),
        .LD_MDR(LD_MDR),
        .LD_IR(LD_IR),
        .LD_BEN(LD_BEN),
        .LD_REG(LD_REG),
        .LD_CC(LD_CC),
        .LD_PC(LD_PC),
        .LD_VEC(LD_VEC),
        .LD_EXCV(LD_EXCV),
        .LD_PRIV(LD_PRIV),
        .LD_USP(LD_USP),
        .LD_SSP(LD_SSP),
        .LD_VA(LD_VA),
        .LD_PFN(LD_PFN),
        .LD_PTE(LD_PTE),
        .LD_SAVED_PSR(LD_SAVED_PSR),
        
        .GATE_PC(GATE_PC),
        .GATE_MDR(GATE_MDR),
        .GATE_ALU(GATE_ALU),
        .GATE_MARMUX(GATE_MARMUX),
        .GATE_SHF(GATE_SHF),
        .GATE_PCSUB(GATE_PCSUB),
        .GATE_PSR(GATE_PSR),
        .GATE_R6(GATE_R6),
        .GATE_VEC(GATE_VEC),
        .GATE_SP(GATE_SP),
        .GATE_PTBR(GATE_PTBR),
        .GATE_VA(GATE_VA),
        .GATE_PTE(GATE_PTE),
        .GATE_SAVED_PSR(GATE_SAVED_PSR),
        
        .PTEMUX(PTEMUX),
        .INMARMUX(INMARMUX),
        .R6MUX(R6MUX),
        .R6INMUX(R6INMUX),
        .VECMUX(VECMUX),
        .SPMUX(SPMUX),
        .PRIMUX(PRIMUX),
        .PSRMUX(PSRMUX),
        .PCMUX(PCMUX),
        .DRMUX(DRMUX),
        .SR1MUX(SR1MUX),
        .ADDR1MUX(ADDR1MUX),
        .ADDR2MUX(ADDR2MUX),
        .MARMUX(MARMUX),
        .ALUK(ALUK),
        .MDRMUX(MDRMUX),
        
       // .SR2MUX(IR[5]),
        
        // Status Outputs to Controller
        .IR_OUT(IR),
        .BEN_OUT(BEN),
        
        .MIO_EN(MIO_EN),
        .DATA_SIZE(DATA_SIZE),
        
        
        // Mem Interface 
        .MAR_OUT(MEM_ADDR), 
        .MDR_OUT(OUT_DATA), // Data leaving the CPU to be written
        .IN_DATA(IN_DATA),   // Data coming from Memory into INMUX
        
        .CHECK_UNALIGNED(CHECK_UNALIGNED),
        .CHECK_PTE(CHECK_PTE),
        
        
        .INTV(INTV),
        
        
        // Generate EXC_flag for Controller module 
        .EXC_flag(EXC_flag)
    );


//    // 3. Block RAM

//    Mem sys_ram (
//        .clk(clk),
//        .MIO_EN(MIO_EN),
//        .R_W(R_W),
//        .DATA_SIZE(DATA_SIZE),
//        .MAR(MEM_ADDR),
//        .MDR_OUT(OUT_DATA),
//        .IN_DATA(IN_DATA),
//        .R(MEM_READY)
//    );


endmodule
