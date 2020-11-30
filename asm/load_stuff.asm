.data
msg0: .ascii "messing around with the lbu stuff"
.text
li $t1, 0x10010000    	#base address
la $a0, msg0

lhu $t0, 0x00($t1)
# # lhu $t0, 0x00($s0)
# lui $t0, 1
# li $t0, 0x12345678
# li $t1, 0x10010000
# sb $t0, 0x00($t1)
# lb $s1, 0x00($t1)
# sh $t0, 0x08($t1)
# lb $s1, 0x08($t1)

addi $a0,$t0,0      #set syscall type to print int
addi $v0,$zero,1          #set syscall type to print int
SYSCALL               #print $a0
addi $v0,$zero,10     #set syscall type to exit
SYSCALL               #exit
