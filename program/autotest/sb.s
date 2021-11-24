# TAG = sb
	.text

	lw x1, (ho)
	li x2, 0x4242
	sb x2, 0(x1)
	lw x31, 0(x1)

	li x2, 0x5252
	sb x2, 4(x1)
	lw x31, 4(x1)

	li x2, 0x6262
	sb x2, 8(x1)
	lw x31, 8(x1)

	.data
hey:
	.word 0x00, 0x00, 0x00
ho:
	.word hey

	# max_cycle 100
	# pout_start
	# 00000042
	# 00000052
	# 00000062
	# pout_end
