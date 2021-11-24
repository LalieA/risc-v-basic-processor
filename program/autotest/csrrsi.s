# TAG = csrrsi
	.text

	li x1, 0x4
	li x3, 0x8
	or x4, x1, x3
	li x5, -1
	slli x5, x5, 2
	and x5, x5, x4

	csrrsi x0, mtvec, 0x4
	csrrsi x0, mtvec, 0x8
	csrrsi x2, mtvec, 0

	beq x5, x2, oui
	li x31, 1
oui:
	li x31, 2

	csrrsi x0, mie, 0x4
	csrrsi x0, mie, 0x8
	csrrsi x2, mie, 0

	beq x4, x2, oui2
	li x31, 1
oui2:
	li x31, 3

	csrrsi x0, mstatus, 0x4
	csrrsi x0, mstatus, 0x8
	csrrsi x2, mstatus, 0

	beq x4, x2, oui3
	li x31, 1
oui3:
	li x31, 4

	csrrsi x0, mepc, 0x4
	csrrsi x0, mepc, 0x8
	csrrsi x2, mepc, 0

	beq x5, x2, oui4
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
