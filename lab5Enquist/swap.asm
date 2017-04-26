#   sum.asm	John Enquist “cricket”	6 April 2002
#   Elementary program to add three numbers and store and print the sum.
#   Register use:
#	$t0: temporary storage for data to be summed
#	$t1: accumulates the sum
#	$v0, $a0: hold parameters to syscall

        .data                   # FYI: start of data section
num1:   .word    0              # three initial integer values
num2:   .word    1 
ar: 	.word 	 1, 2, 3 	#a 4 element array
sum:    .space    3              # allocate a word for the integer result

        .text                   # FYI: start of code section
        .align 2                # FYI: align to start code on a word boundary
        .globl main             # FYI: make 'main' visible to the simulator
main:                           # main() {
	
	la   $t0, ar		# loading address of array into $t0
	lw   $t1, num1
	lw   $t2, num2
	sll  $t1, $t1, 2	# t1 now holds array address of 1
	sll  $t2, $t2, 2	# t2 now holds array address of 2
	add  $t3, $t0, $t1	# t1 word address in array
	lw   $t5, 0($t3)
	add  $t4, $t0, $t2	# t2 word address in array
	lw   $t6, 0($t4)
	sw   $t6, 0($t3)
	sw   $t5, 0($t4)
        addi $v0, $0, 1         #    $v0   = code for 'print-int'
        add  $a0, $0, $t1       #    $a0   = accum
        
        syscall                 #    syscall($v0=1) prints $a0
        jr   $ra                #    return control to the simulator
                                # }
