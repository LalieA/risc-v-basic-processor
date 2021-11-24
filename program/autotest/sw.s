# TAG = sw
	.text

	lw x1, (ho)
	addi x2, x0, 0x42
	sw x2, 0(x1)
	lw x31, 0(x1)

	addi x2, x0, 0x52
	sw x2, 4(x1)
	lw x31, 4(x1)

	addi x2, x0, 0x62
	sw x2, 8(x1)
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
