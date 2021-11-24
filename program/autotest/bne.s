# TAG = bne
	.text

    addi x31, x0, 0

    addi x1, x0, 5
    addi x2, x0, 5
    bne x1, x2, not_equal
    addi x31, x0, 1
not_equal:
    addi x31, x0, 2

    addi x1, x0, 5
    addi x2, x0, -5
    bne x1, x2, equal
    addi x31, x0, 3
equal:
    addi x31, x0, 4

    addi x1, x0, 5
    addi x2, x0, 7
    bne x1, x2, salut
    addi x31, x0, 5
salut:
    addi x31, x0, 6

	# max_cycle 100
	# pout_start
	# 00000000
    # 00000001
    # 00000002
    # 00000004
    # 00000006
	# pout_end
