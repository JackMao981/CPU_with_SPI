# This program outputs the gcd between $a0 and $a1
addi $a0, $zero, 0				# Input
addi $a1, $zero, 1				# Input
addi $t0, $a0, 0				# divisor
addi $t1, $a1, 0				# dividend
	
R1:
	beq $t0, 0, breakloop			# if divisor is 0, breakloop
	sub $t4, $t0, $t1			# see if the divisor is bigger than the dividend
	blez $t4, R2				# if the previous statement is true, go to R2
	addi $t4, $t1, 0			# set $t4 as a temp for the dividend
	addi $t1, $t0, 0			# if not, swap the dividend and the divisor
	addi $t0, $t4, 0			# swap the divisor with the temp dividend
	j R1	
R2:						# this is if the dividend is bigger than the divisor 
	sub $t4, $zero, $t4			# make the comparator positive, since this is the remainder
	addi $t1, $t0, 0			# sets divisor to be next dividend 
	addi $t0, $t4, 0			# Remainder becomes the next divisor
	j R1
	
breakloop:
    add $a0,$zero,$t1     #return the answer
    addi $v0,$zero,1      #set syscall type to print int
    SYSCALL               #print $a0
    addi $v0,$zero,10     #set syscall type to exit 
    SYSCALL               #exit
