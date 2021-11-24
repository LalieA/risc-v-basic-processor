# TAG = bge
	.text

    addi x31, x0, 0

    addi x1, x0, 5
    addi x2, x0, 5
    bge x1, x2, a
    addi x31, x0, 1
a:
    addi x31, x0, 2

    addi x1, x0, 5
    addi x2, x0, -5
    bge x1, x2, b
    addi x31, x0, 3
b:
    addi x31, x0, 4

    addi x1, x0, 5
    addi x2, x0, 7
    bge x1, x2, c
    addi x31, x0, 5
c:
    addi x31, x0, 6

	# max_cycle 100
	# pout_start
	# 00000000
    # 00000002
    # 00000004
    # 00000005
    # 00000006
	# pout_end
