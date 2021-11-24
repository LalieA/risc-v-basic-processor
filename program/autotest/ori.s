# TAG = ori
	.text

	addi x30, x0, 0x00f
	ori x31, x30, 0x0f0

	addi x30, x0, 0x7f0
	ori x31, x30, 0x0ff

	# max_cycle 50
	# pout_start
	# 000000ff
	# 000007ff
	# pout_end
