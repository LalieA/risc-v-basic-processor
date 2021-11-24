# TAG = and
	.text

	addi x30, x0, 0x7ff
	addi x29, x0, 0x70f
	and x31, x30, x29

	addi x29, x0, 0x70f
	addi x30, x0, 0x0f0
	and x31, x30, x29

	# max_cycle 50
	# pout_start
	# 0000070f
	# 00000000
	# pout_end
