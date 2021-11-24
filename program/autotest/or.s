# TAG = or
	.text

	addi x29, x0, 0x00f
	addi x30, x0, 0x0f0
	or x31, x30, x29

	addi x30, x0, 0x7f0
	addi x29, x0, 0x0ff
	or x31, x30, x29

	# max_cycle 50
	# pout_start
	# 000000ff
	# 000007ff
	# pout_end
