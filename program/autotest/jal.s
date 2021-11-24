# TAG = jal
	.text

    jal x31, end
    li x31, 1
end:
    li x31, 2

	# max_cycle 100
	# pout_start
	# 00001004
    # 00000002
	# pout_end
