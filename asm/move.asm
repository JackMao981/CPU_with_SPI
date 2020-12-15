addi $t1, $zero, 0x00000aaa
# addi $t1, $zero, 0x0bba

## MOSI TEST
## MOSI: $t2
## MOSI S: $t3
## MOSI DV: $t4
# start_mosi:
#   mtc0 $t1, $t3
#   li $t2, 1
#   mtc0 $t2, $t4
# mosi:
#   mfc0 $t3, $t5
#   bne  $t3, $zero, finish
#   j mosi


# MISO TEST
## MISO:    $t0
## MISO S:  $t1
## MISO_DV: $t2
start_miso:
  li $t2, 1
  # mtc0 $t2, $t1
  mtc0 $t2, $t7
miso:
  mfc0 $t4, $t0
  mfc0 $t6, $t2
  bne  $t6, $zero, finish
  j miso



finish:
  add $a0,$zero,$t2
  addi $v0,$zero,1
  SYSCALL
  addi $v0,$zero,10
  SYSCALL
