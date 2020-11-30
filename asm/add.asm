# Test Program to Add two numbers
.text
asdf:
  # addi $a0, $zero, 0        # sim
  # addi $t0, $zero, 123981      # a
  # li $t1, 48	 # b
  la $a0 fibs
  li $t0 1
  sw $t0, 0($a0)

asdf1:
  # addi $a0,$t1,0        #return the answer
  lw  $a0, 0($t0)
  addi $v0,$zero,1          #set syscall type to print int
  SYSCALL                   #print $a0
  addi $v0,$zero,10         #set syscall type to exit
  SYSCALL                   #exit


  .data
  fibs: .word 0 : 100
  len:  .word 20
