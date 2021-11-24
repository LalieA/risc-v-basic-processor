# TAG = sub
	.text

	# Test add
	addi x30, x0, 5
	addi x29, x0, -4
	sub x31, x30, x29

	# Test sub
	addi x30, x0, 4
	sub x31, x31, x30

	# Test wrap
	addi x30, x0, -2048
	addi x29, x0, 1
	sub x31, x30, x29

	# max_cycle 50
	# pout_start
	# 00000009
	# 00000005
	# fffff7ff
	# pout_end
