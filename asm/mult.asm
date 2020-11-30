# for fun so we didn't comment much
# this helped with factorial
addi $a0, $zero, 5
addi $a1, $zero, 4
add $t1, $zero, $a0	# b
add $t2, $zero, $a1     # product
addi $t3, $zero, 0     # counter

loop:
     blez $t0, breakloop
     blez $t1, breakloop
     addi $t3, $t3, 1
     add $t2, $t1, $t2
     beq $t3, $t0, breakloop
     j loop

breakloop:
    add $a0,$zero,$t2
    addi $v0,$zero,1
    SYSCALL
    addi $v0,$zero,10
    SYSCALL
