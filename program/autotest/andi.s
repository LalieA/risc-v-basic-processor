# TAG = andi
	.text

	addi x30, x0, 0x7ff
	andi x31, x30, 0x70f

	addi x30, x0, 0x70f
	andi x31, x30, 0x0f0

	# max_cycle 50
	# pout_start
	# 0000070f
	# 00000000
	# pout_end
