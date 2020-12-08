addi $t0, $zero, 0x16
# addi $t1, $zero, 0x0bba

# mosi:
#   mtc0 $t0, 0
#
miso:
  mfc0 $t1, 0
  beq  $t1, $t0, finish
  # addi $t1, $zero, 0x16
  j miso

# mfc0 $t1, 2

finish:
  add $a0,$zero,$t1
  addi $v0,$zero,1
  SYSCALL
  addi $v0,$zero,10
  SYSCALL
