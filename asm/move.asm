addi $t0, $zero, 5

mosi:
mtc0 $t0, 0

# miso:
# mfc0 $t1, 1

add $a0,$zero,$t0
addi $v0,$zero,1
SYSCALL
addi $v0,$zero,0
SYSCALL
