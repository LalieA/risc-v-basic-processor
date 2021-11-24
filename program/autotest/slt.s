# TAG = slt
	.text

    addi x31, x0, 0xff

    addi x1, x0, 5
    addi x2, x0, 5
    slt x31, x1, x2

    addi x31, x0, 0xff

    addi x1, x0, 5
    addi x2, x0, -5
    slt x31, x1, x2

    addi x31, x0, 0xff

    addi x1, x0, 5
    addi x2, x0, 7
    slt x31, x1, x2

	# max_cycle 50
	# pout_start
	# 000000ff
    # 00000000
    # 000000ff
    # 00000000
    # 000000ff
    # 00000001
	# pout_end
