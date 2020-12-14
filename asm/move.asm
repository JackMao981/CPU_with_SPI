addi $t1, $zero, 0x00000aaa
# addi $t1, $zero, 0x0bba

# MOSI TEST
# MOSI: $t2
# MOSI S: $t3
# MOSI DV: $t4
mtc0 $t1, $t2

li $t2, 1
mtc0 $t2, $t3
mosi:
mfc0 $t3, $t4
bne  $t3, $zero, finish
j mosi



# MISO TEST
# MISO:    $t0
# MISO_DV: $t1
# miso1:
#   mfc0 $t2, $t0
#   mfc0 $t3, $t1
#   bne  $t3, $zero, miso2
#   # # addi $t1, $zero, 0x16
#   j miso1
#
# miso2:
#   mfc0 $t4, $t0
#   mfc0 $t3, $t1
#   bne  $t3, $zero, finish
#   # # addi $t1, $zero, 0x16
#   j miso2



finish:
  add $a0,$zero,$t2
  addi $v0,$zero,1
  SYSCALL
  addi $v0,$zero,10
  SYSCALL
