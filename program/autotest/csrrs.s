# TAG = csrrs
	.text

	li x1, 0x42
	li x3, 0x83
	or x4, x1, x3
	li x5, -1
	slli x5, x5, 2
	and x5, x5, x4

	csrrs x0, mtvec, x1
	csrrs x0, mtvec, x3
	csrrs x2, mtvec, x0

	beq x5, x2, oui
	li x31, 1
oui:
	li x31, 2

	csrrs x0, mie, x1
	csrrs x0, mie, x3
	csrrs x2, mie, x0

	beq x4, x2, oui2
	li x31, 1
oui2:
	li x31, 3

	csrrs x0, mstatus, x1
	csrrs x0, mstatus, x3
	csrrs x2, mstatus, x0

	beq x4, x2, oui3
	li x31, 1
oui3:
	li x31, 4

	csrrs x0, mepc, x1
	csrrs x0, mepc, x3
	csrrs x2, mepc, x0

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
