.text
la $t0 len
lw $a0, 0($t0)
la $a1 fibs
li $t0 1
sw $t0, 0($a1)
li $t1 1
sw $t1, 4($a1)
li $t3 2
#
loop:
    add $t2, $t0, $t1
    sll $t4, $t3, 2
    add $t4, $t4, $a1
    sw  $t2, 0($t4)
    beq $t3,$a0,done
    move $t0, $t1
    move $t1, $t2
    addi $t3, $t3, 1
    j loop

done:
    sll $t4, $a0, 2
    add $t4, $t4, $a1
    lw  $a0, 0($t4)
    addi $v0,$zero,1      #set syscall type to print int
    SYSCALL               #print $a0
    addi $v0,$zero,10     #set syscall type to exit
    SYSCALL               #exit
.data
fibs: .word 0 : 100
len:  .word 20
