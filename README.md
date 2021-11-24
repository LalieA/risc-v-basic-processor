# RISC-V basic processor

The goal of this project is to build a RISC-V processor which can be integrated in a complete system to run an application that performs a display on screen. The processor is built in two parts, the control part and the operative part.

Implemented instructions :
- Basic : lui
- Arithmetic : add, addi, sub
- Logic : or, ori, and, andi, xor, xori
- Loads : lb, lbu, lh, lhu, lw
- Stores : sb, sh, sw
- Sets : slt, slti, sltiu, sltu
- Offsets : sll, slli, sra, srai, srl, srli
- Connections : beq, bge, bgeu, blt, bltu, bne
- Jumps : jal, jalr
- Interruptions : csrrc, csrrci, csrrs, csrrsi, csrrw, csrrwi, it
- Others : auipc


Project optional feature : interruptions handling.


A test program has been written in C; it consists in generating an array of 10 pseudo-random integers and sorting it. This program has been manually translated into assembler, and can be run on this processor using an emulator like QEMU.

This work was done as part of Conception and Exploitation of Processors project in the first year of engineering courses at Grenoble INP - Ensimag, UGA.
