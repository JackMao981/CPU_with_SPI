# We are computing the factorial of $a0
addi $a0, $zero, 10       	# input
addi $t0, $zero, 1 		# current number, counts loop
addi $t1, $zero, 0 		# placeholder for the previous total
addi $t2, $zero, 1		# the total product
addi $t3, $zero, 0 		# counting the number of times t1 has been added

loop:
#    blez $a0, breakloop
    subi $t4, $a0, 1		# fixes edge cases
    blez $t4, breakloop		#exits if edge case
    addi $t3, $zero, 0		# reset count
    add $t1, $zero, $t2 	# sets placeholder to be the previous product
    j multiloop			# jump to multiloop

multiloop:			# multiplies by adding alot
    addi $t3, $t3, 1   	# increments the counter by 1
    add $t2, $t1, $t2		# add placeholder to the final product 
    beq $t3, $t0, breakmult	# if counter is the same current number, go to breakmult
    j multiloop

breakmult:
    addi $t0,$t0,1		# adds 1 to current
    beq $t0,$a0,breakloop 	# if next = a0 then breakloop
    j loop                	# jumps all the way back to the loop

breakloop:			# outputs the product
    add $a0,$zero,$t2
    addi $v0,$zero,1
    SYSCALL
    addi $v0,$zero,10
    SYSCALL
