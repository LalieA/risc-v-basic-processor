# TAG = add
	.text

	# Test add
	addi x29, x0, 5
	addi x30, x0, 4
	add x31, x30, x29

	# Test sub
	addi x30, x0, -4
	add x31, x31, x30

	# Test wrap
	addi x29, x0, -1 # max
	addi x30, x0, 5
	add x31, x30, x29

	# max_cycle 50
	# pout_start
	# 00000009
	# 00000005
	# 00000004
	# pout_end
