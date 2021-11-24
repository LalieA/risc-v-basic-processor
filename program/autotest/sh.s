# TAG = sh
	.text

	lw x1, (ho)
	li x2, 0x420042
	sh x2, 0(x1)
	lw x31, 0(x1)

	li x2, 0x520052
	sh x2, 4(x1)
	lw x31, 4(x1)

	li x2, 0x620062
	sh x2, 8(x1)
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
