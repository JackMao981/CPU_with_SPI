addi $t1, $zero, 0x16
# addi $t1, $zero, 0x0bba
#
# mosi:
# mtc0 $t1, $t0
# mfc0 $t3, $zero
# bne  $t3, $zero, finish
# j mosi

# MISO:    $t0
# MISO_DV: $t1
miso:
  mfc0 $t2, $t0
  mfc0 $t3, $t1
  bne  $t3, $zero, finish
  # # addi $t1, $zero, 0x16
  j miso

# mfc0 $t1, 2


finish:
  add $a0,$zero,$t2
  addi $v0,$zero,1
  SYSCALL
  addi $v0,$zero,10
  SYSCALL
