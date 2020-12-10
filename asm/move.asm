addi $t1, $zero, 0x16
# addi $t1, $zero, 0x0bba

mosi:
  mtc0 $t1, $t0
#
miso:
  mfc0 $t2, $t0 # copies register zero from the coprocessor to register t1
              # look at mfc0 in the hex file
  beq  $t1, 0x1, finish #compare to dv_reg
  # # addi $t1, $zero, 0x16
  j miso

# mfc0 $t1, 2


finish:
  add $a0,$zero,$t2
  addi $v0,$zero,1
  SYSCALL
  addi $v0,$zero,10
  SYSCALL
