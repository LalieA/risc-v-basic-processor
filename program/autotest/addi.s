# TAG = addi
	.text

	addi x31, x0, 5      # Test addition
	addi x31, x31, -2    # Test soustraction
	addi x31, x31, -15	 # Test negatif
	addi x31, x31, 2047  # Test max

	# max_cycle 50
	# pout_start
	# 00000005
	# 00000003
	# fffffff4
	# 000007f3
	# pout_end
