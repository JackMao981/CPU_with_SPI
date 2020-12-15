li $t8, 0xf000
li $t9, 0x000d
sll $t8, $t8, 16
addu $t1, $t8, $t9
# addi $t1, $zero, 0x0bba

## MOSI TEST
## MOSI: $t3
## MOSI S: $t4
## MOSI DV: $t5
start_mosi:
  mtc0 $t1, $t3
  li $t2, 1
  mtc0 $t2, $t4
mosi:
  mfc0 $t3, $t5
  bne  $t3, $zero, start_miso
  j mosi


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
  add $a0,$zero,$t4
  addi $v0,$zero,1
  SYSCALL
  addi $v0,$zero,10
  SYSCALL
