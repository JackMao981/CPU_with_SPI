addi $a0, $zero, 5        #assume N>=2 argument provided in a0
addi $t0, $zero, 1        #F_(n-1)
addi $t1, $zero, 1        #F_(n-2)
addi $t2, $zero, 2        #n
                          #t3 is F_n
loop:
    add $t3,$t0,$t1       #F_n=F_(n-1)+F_(n-2)
    beq $t2,$a0,breakloop #if (n==N) goto breakloop;
    addi $t2,$t2,1        #n++
    add $t1,$zero,$t0     #F_(n-2)=F_(n-1)
    add $t0,$zero,$t3     #F_(n-1)=F_n
    j loop                #restart loop

breakloop:
    add $a0,$zero,$t3     #return the answer
    addi $v0,$zero,1      #set syscall type to print int
    SYSCALL               #print $a0
    addi $v0,$zero,10     #set syscall type to exit
    SYSCALL               #exit
