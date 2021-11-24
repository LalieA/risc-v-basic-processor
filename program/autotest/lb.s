# TAG = lb
	.text

	lw x10, (ho)
	lb x31, 0(x10)
	lb x31, 4(x10)
	lb x31, 8(x10)
	lb x31, 12(x10)

	.data
hey:
	.word 0x42, 0x52, 0x62, 0x80
ho:
	.word hey

	# max_cycle 50
	# pout_start
	# 00000042
	# 00000052
	# 00000062
	# ffffff80
	# pout_end
