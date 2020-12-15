li $t8, 0xf000
li $t9, 0x000d
sll $t8, $t8, 16
addu $t1, $t8, $t9
# addi $t1, $zero, 0x0bba

# MOSI TEST
# REG MOSI: $t3
# REG MOSI S: $t4
# REG MOSI TR: $t5
# How to send message
# 1. Load data into REG MOSI
# 2. Load a 1 into REG MOSI S to start sending message
# 3. Check REG MOSI TR. When it is 1, data has finished sending
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
# How to receive message
# 1. Load a 1 into REG MISO S to start sending message
# 2. Keep storing REG MISO
# 3. Check REG MISO DV. When it is 1, data has finished receiving
start_miso:
  li $t2, 1
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
