# TAG = csrrw
	.text

	lui x1, %hi(oui)
	addi x1, x0, %lo(oui)
	li x3, -1
	slli x3, x3, 2
	and x3, x3, x1

	csrrw x0, mtvec, x1
	csrrw x2, mtvec, x0

	beq x3, x2, oui
	li x31, 1
oui:
	li x31, 2

	csrrw x0, mie, x1
	csrrw x2, mie, x0

	beq x1, x2, oui2
	li x31, 1
oui2:
	li x31, 3

	csrrw x0, mstatus, x1
	csrrw x2, mstatus, x0

	beq x1, x2, oui3
	li x31, 1
oui3:
	li x31, 4

	csrrw x0, mepc, x1
	csrrw x2, mepc, x0

	beq x3, x2, oui4
	li x31, 1
oui4:
	li x31, 5

	# max_cycle 100
	# pout_start
    # 00000002
    # 00000003
    # 00000004
    # 00000005
	# pout_end
