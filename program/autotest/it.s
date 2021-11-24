# TAG = it
    .text

    lui x1, %hi(handler)
    addi x1, x0, %lo(handler)
    csrrw x0, mtvec, x1

    # MIE = 1
    li x1, 1 << 3
    csrrw x0, mstatus, x1

    # Bouton PLIC
    li x1, 1 << 2
    lui x2, 0x0c002
    sw x1, (x2)

    # MEIE = 1
    addi x1, x0, 0x7ff
    addi x1, x1, 1
    csrrs x0, mie, x1

    li x31, 0

while:
    beqz x31, while
    li x31, 0x52
    j end

handler:
    li x31, 0x42
    # Acquitte bouton
    li x3, 0x0c200004
    lw x1, (x3)
    mret

end:
    li x1, 0

    # max_cycle 200
    # pout_start
    # 00000000
    # 00000042
    # 00000052
    # pout_end
    # irq_start
    # 100
    # irq_end
