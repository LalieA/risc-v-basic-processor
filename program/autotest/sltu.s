# TAG = sltu
	.text

    addi x31, x0, 0xff

    addi x1, x0, 5
    addi x2, x0, 5
    sltu x31, x1, x2

    addi x31, x0, 0xff

    addi x1, x0, 5
    addi x2, x0, -5
    sltu x31, x1, x2

    addi x31, x0, 0xff

    addi x1, x0, 5
    addi x2, x0, 7
    sltu x31, x1, x2

	# max_cycle 50
	# pout_start
	# 000000ff
    # 00000000
    # 000000ff
    # 00000001
    # 000000ff
    # 00000001
	# pout_end
