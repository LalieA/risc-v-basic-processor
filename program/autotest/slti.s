# TAG = slti
	.text

    addi x31, x0, 0xff

    addi x1, x0, 5
    slti x31, x1, 5

    addi x31, x0, 0xff

    addi x1, x0, 5
    slti x31, x1, -5

    addi x31, x0, 0xff

    addi x1, x0, 5
    slti x31, x1, 7

	# max_cycle 50
	# pout_start
	# 000000ff
    # 00000000
    # 000000ff
    # 00000000
    # 000000ff
    # 00000001
	# pout_end
