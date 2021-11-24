# TAG = xori
	.text

	addi x30, x0, 0x00f
	xori x31, x30, 0x0f1

	addi x30, x0, 0x7f0
	xori x31, x30, 0x0ff

	# max_cycle 50
	# pout_start
	# 000000fe
	# 0000070f
	# pout_end
