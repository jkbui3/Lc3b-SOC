This repository contains the complete RTL implementation and physical FPGA synthesis of a custom LC-3b System-on-Chip (SoC). Designed using Vivado Verilog and deployed on a Xilinx Artix-7 FPGA (Basys 3), this project aims to demonstrate bridging the gap between low-level computer architecture and physical hardware integration.

This is a fully functional, interrupt-driven microarchitecture. It features a memory-mapped I/O (MMIO) bus, a hardware UART module for PC communication, and architectural states to support modern computing requirements.

# Architectural Highlights


CPU Core: A 64-state LC-3b datapath and controller with hardware support for Interrupts (INT), Exceptions (EXC), Virtual Memory (VM), and Return from Interrupt (RTI) sequences.

Complete Schematics: Includes comprehensive architectural diagrams detailing the expanded datapath routing and state machine logic required for advanced privilege modes and exception handling.

Master-Slave Bus Architecture: Features a MMIO controller that routes execution traffic between the CPU core, RAM, and external physical peripherals(through UART).

Hardware-Software Integration: Features a 115200-baud UART transceiver and GPIO routing, completely eliminating simulation race conditions through timing closure and power-on register initialization.

Bare-Metal Execution: Capable of running compiled assembly and bare-metal firmware directly from silicon SRAM.

# Design Decisions & Challenges


Timing Closure & Custom Clock Domains:

Initial synthesis at the Basys 3's 100MHz clock revealed setup time violations (negative slack) across two critical datapath routes due to physical wire propagation delays. I analyzed the timing report-total negative slack -0.760ns, calculated the maximum logic delay, and used Clocking Wizard IP to generate a 95MHz sys_clk. This guaranteed timing closure across all 82,000+ endpoints while maintaining maximum performance.


Hierarchical Refactoring for Modularity:

To address the timing bottlenecks, the project hierarchy was restructured to isolate the Lc3b_Core from the FPGA_Top wrapper. This decoupled the CPU's internal logic from the external MMIO and physical board constraints. This modular architecture enables isolated simulation testbenches for the core alone, and allows targeted redesigns of specific slow modules without disrupting the memory bus or peripheral routing.


Controller Microarchitecture & State Optimization:

The CPU's control unit was implemented as a strict 64-state/6-bit maximum. Implementing the baseline LC3b instruction set alongside features like Interrupts, Exceptions, and Virtual Memory required an extensive amount of state sharing as well as additional datapath elements and BUS management as will be shown below.

# Micro-arch

Top layout:
<img width="2860" height="2168" alt="CamScanner 5-13-26 11 28_3" src="https://github.com/user-attachments/assets/71752f7d-f9a4-415f-95f6-54898d8896d8" />

original state machine supports baseline microinstructions:
<img width="2550" height="3300" alt="lc3b_og_state_machine" src="https://github.com/user-attachments/assets/c703a980-8563-4bfc-9211-62993d0650ca" />

modified with additional states state machine:

<img width="2668" height="3460" alt="CamScanner 5-13-26 11 13_1" src="https://github.com/user-attachments/assets/a13b3918-5e5b-4f7a-b80c-72acb9674f35" />
Interrupts and Exeception handling/context switch additional logic

<img width="2728" height="3548" alt="CamScanner 5-13-26 11 13_2" src="https://github.com/user-attachments/assets/c8262042-e4f4-4cf0-b12e-360158cb27dc" />
RTI logic

<img width="2548" height="3256" alt="CamScanner 5-13-26 11 13_3" src="https://github.com/user-attachments/assets/fb0902c1-6138-4802-a34e-87c36839c08f" />
Virtual Memory translation logic


Original Datapath:
<img width="2550" height="3300" alt="lc3b_og_datapath" src="https://github.com/user-attachments/assets/be24daa9-b79d-482f-91d4-a9fa21cf1a13" />

Modified datapath and additional modules:
<img width="2496" height="3860" alt="CamScanner 5-13-26 11 28_1" src="https://github.com/user-attachments/assets/9d66c3fb-d9d6-4ce0-8ea1-c00bcc899bd0" />
<img width="1992" height="2544" alt="CamScanner 5-13-26 11 28_2" src="https://github.com/user-attachments/assets/ee8ca154-edbf-4d6d-8d75-2a0d3c5725c5" />

# Control store
[Lab5 Control Store_ucode_V0.xlsx](https://github.com/user-attachments/files/27719844/Lab5.Control.Store_ucode_V0.xlsx)

# Original LC3b documentations(ISA & Microarch) by Yale Patt
[appA.pdf](https://github.com/user-attachments/files/27719927/appA.pdf)

[lc3b_arch.pdf](https://github.com/user-attachments/files/27719938/lc3b_arch.pdf)


