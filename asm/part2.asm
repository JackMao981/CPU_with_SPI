li $t0 1
li $t1 2
add  $t2, $t0, $t1
sll  $t3, $t2, 4
srav $t4, $t3, $t1
xori $t5, $t4, 15
sub  $t6, $t5, $t2
or   $t7, $t6, $t3
li   $t0, -8
add  $t1, $t7, $t0
srl  $t2, $t1, 2
addi $a0, $t2, 32
li $v0 1
syscall
li $v0 10
syscall
