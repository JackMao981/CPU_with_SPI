addi $t0, $zero, 0x1FFF
addi $t1, $zero, 0x0001
# mosi:
# mtc0 $t0, 0

miso:
  mfc0 $t1, 2
  # bne  $t1, $t0, finish
  # j miso

finish:
  add $a0,$zero,$t1
  addi $v0,$zero,1
  SYSCALL
  addi $v0,$zero,10
  SYSCALL
