# TAG = jalr
	.text

	li x1, 0x1000
    jalr x31, 12(x1)
    li x31, 1
    li x31, 2

	# max_cycle 100
	# pout_start
	# 00001008
    # 00000002
	# pout_end
