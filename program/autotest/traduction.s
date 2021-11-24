# TAG = traduction
    .text
    .globl demo
    .globl xorshift

entry:
    # Contexte
    # sp+0 : random_holder rand
    addi sp, sp, -8

    li t0, 5
    sw t0, 0(sp)
    
    lui t0, %hi(xorshift)
    addi t0, t0, %lo(xorshift)
    sw t0, 4(sp)

    mv a0, sp
    jal demo

    addi sp, sp, 8
    j end

tri_insertion:
    # Contexte:
    # a0 : tab
    # a1 : taille
    # t0 : i
    # t1 : elem
    # t2 : j
    # t3 : tmp
    # t4 : tmp2

    li t0, 1
tri_insertion_loop_outer:
    # for (...; i < taille; ...)
    bge t0, a1, tri_insertion_loop_outer_end

    # elem = tab[i]
    slli t3, t0, 2
    add t3, a0, t3
    lw t1, (t3)

    # j = i
    mv t2, t0
tri_insertion_loop_inner:
    # for (...; j > 0 && tab[j-1] > elem; ...)
    blez t2, tri_insertion_loop_inner_end
    addi t3, t2, -1
    slli t3, t3, 2
    add t3, a0, t3
    lw t3, (t3)
    ble t3, t1, tri_insertion_loop_inner_end

    # tab[j] = tab[j-1]
    slli t4, t2, 2
    add t4, a0, t4
    sw t3, (t4)

    # j--
    addi t2, t2, -1
    j tri_insertion_loop_inner
tri_insertion_loop_inner_end:

    # tab[j] = elem
    slli t4, t2, 2
    add t4, a0, t4
    sw t1, (t4)
    
    # i++
    addi t0, t0, 1
    j tri_insertion_loop_outer
tri_insertion_loop_outer_end:

    ret

xorshift:
    # Contexte:
    # a0 : uint32 state
    # t0 : tmp

    # state ^= state << 13
    slli t0, a0, 13
    xor a0, a0, t0
    # state ^= state >> 17
    srli t0, a0, 17
    xor a0, a0, t0
    # state ^= state << 5
    slli t0, a0, 5
    xor a0, a0, t0

    # return state
    ret

demo:
    # Contexte:
    # sp+0 : ra
    # sp+4 : rand*
    # sp+8 : i
    # sp+12 : tableau[0]
    # sp+16 : tableau[1]
    # ...
    # sp+48 : tableau[9]
    #
    # a0 : random_holder* rand
    #
    # t0 : state
    # t1 : i
    # t2 : cst

    addi sp, sp, -52
    sw ra, 0(sp)
    sw a0, 4(sp)

    # i = 0
    li t1, 0
demo_loop_entry:
    # for (...; i < 10; ...)
    lw t1, 8(sp)
    li t2, 10
    bge t1, t2, demo_loop_end

    # rand->state = rand->handler(rand->state)
    lw t0, 4(sp)
    lw a0, 0(t0)
    lw t0, 4(t0)
    jalr (t0)
    lw t0, 4(sp)
    sw a0, 0(t0)
    mv t0, a0

    # tableau[i] = rand->state & 0xffff
    li t2, 0xffff
    and t0, t0, t2
    lw t1, 8(sp)
    slli t2, t1, 2
    add t2, sp, t2
    addi t2, t2, 12
    sw t0, (t2)

    # i++
    addi t1, t1, 1
    sw t1, 8(sp)
    j demo_loop_entry
demo_loop_end:

#     sw zero, 8(sp)
# p:
#     lw t1, 8(sp)
#     li t2, 10*4
#     bge t1, t2, pp

#     lui a0, %hi(fmt)
#     addi a0, a0, %lo(fmt)
#     addi a1, sp, 12
#     add a1, a1, t1
#     lw a1, (a1)
#     jal printf

#     lw t1, 8(sp)
#     addi t1, t1, 4
#     sw t1, 8(sp)
#     j p
# pp:

#     lui a0, %hi(sep)
#     addi a0, a0, %lo(sep)
#     jal printf

    # tri_insertion(tableau, 10)
    addi a0, sp, 12
    li a1, 10
    jal tri_insertion

    sw zero, 8(sp)
p2:
    lw t1, 8(sp)
    li t2, 10*4
    bge t1, t2, pp2

    # lui a0, %hi(fmt)
    # addi a0, a0, %lo(fmt)
    addi a1, sp, 12
    add a1, a1, t1
    lw a1, (a1)
    mv x31, a1 # pout
    # jal printf

    lw t1, 8(sp)
    addi t1, t1, 4
    sw t1, 8(sp)
    j p2
pp2:

    # return 0
    li a0, 0
    lw ra, 0(sp)
    addi sp, sp, 52
    ret

end:
    li x31, 0xbeef

    .data
fmt:
    .string "%lu\n"
    .word 0x0
sep:
    .string "---\n"
    .word 0x0

	# max_cycle 1000
	# pout_start
    # 000019c1
    # 00001e05
    # 00003db7
    # 000047e5
    # 000098e3
    # 00009e31
    # 0000a0a5
    # 0000ad85
    # 0000dae1
    # 0000eb43
	# 0000beef
	# pout_end