# TAG = mret
    .text

    csrrw x0, mstatus, x0
    lui x1, %hi(oui)
    addi x1, x1, %lo(oui)

    csrrw x0, mepc, x1
    mret

    li x31, 1
oui:
    li x31, 2

    csrrc x1, mstatus, x0
    and x1, x1, 8
    bnez x1, oui2
    li x31, 1
oui2:
    li x31, 3

    # max_cycle 50
    # pout_start
    # 00000002
    # 00000003
    # pout_end
