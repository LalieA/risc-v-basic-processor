# TAG = csrrci
	.text

	li x1, 0x7
	li x3, 0x4

	csrrwi x0, mtvec, 0xf
	csrrci x0, mtvec, 0x8
	csrrci x2, mtvec, 0

	beq x3, x2, oui
	li x31, 1
oui:
	li x31, 2

	csrrwi x0, mie, 0xf
	csrrci x0, mie, 0x8
	csrrci x2, mie, 0

	beq x1, x2, oui2
	li x31, 1
oui2:
	li x31, 3

	csrrwi x0, mstatus, 0xf
	csrrci x0, mstatus, 0x8
	csrrci x2, mstatus, 0

	beq x1, x2, oui3
	li x31, 1
oui3:
	li x31, 4

	csrrwi x0, mepc, 0xf
	csrrci x0, mepc, 0x8
	csrrci x2, mepc, 0

	beq x3, x2, oui4
	li x31, 1
oui4:
	li x31, 5

	# max_cycle 150
	# pout_start
    # 00000002
    # 00000003
    # 00000004
    # 00000005
	# pout_end
