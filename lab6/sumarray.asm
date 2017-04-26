## Sum an array with a subroutine.
## David Hemmendinger 4 April 2006, edits by John Rieffel 2011, 2012
##edits also made by john enquist	

PR_INT = 1                   # (example of defining a constant)
        .data
PR_STR = 4
	.data
newline:
	.asciiz "\n"
	.text
	.data
str:
	.asciiz "array sum = "
	.text
	.data
str2:
	.asciiz "sorted array : "
	.text
	.data
comma:
	.asciiz ", "
	.text
	.data
array:  .word 3, 4, 5
endarr:
        .text
        .align 2
main:   
	la $a0, array        # a0 points into array
	la $t0, endarr       # a1 points to array end
	sub $t0, $t0, $a0
	srl $a1, $t0, 2
	addi $sp, $sp, -4      # push 
	sw $ra, 0($sp)         # return address
	jal insertsort
	la $a0, array		# loads address of array into $a0
	jal printarray
	la $a0, array		# loads address of array into $a0
	li $v0, PR_STR
	la $a0, newline
	syscall
	la $a0, array
	jal arraysum	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
#	move $a1, $v0		# moves the contents of v0 into a1
#	li $v0, PR_STR
#	la $a0, str
#	syscall
#	add $a0, $0, $a1     # copy sum into $a0   
#	addi $v0, $0, PR_INT # print code in $v0
#	syscall
	jr $ra                  

## array-sum function
##	$a0: parameter: array address pointer
##	$a1: parameter: points after array
##	$v0: return value
##	$t2: contains current array element

arraysum: 
	move $v0, $0         # v0 accumulates sum
	addi $t1, $0, 0      # counter
	j condition
loop:  	
	sll $t2, $t1, 2		 # shift t1 and load into t2
	add $t2, $t2, $a0	 # t2 holds pointer to current value
	lw $t3, 0($t2)		 # next array element
	add $v0, $v0, $t3        # add sum
	addi $t1, $t1, 1         # increment counter
condition:    
	blt $t1, $a1, loop   # while a0 < endarr do	
	jr $ra

printarray:
	move $t0, $0
	move $t4, $a0
	li $v0, PR_STR
	la $a0, str2
	syscall
	j condit

looop:  	
	sll $t2, $t1, 2		 # t2 = 4*t2
	add $t2, $t2, $t4	 # t2 points to the current value
	lw $t3, 0($t2)
	li $v0, PR_INT
	move $a0, $t3
	syscall
	li $v0, PR_STR		# adding data to print
	la $a0, comma		# adding comma to print
	syscall
	addi $t1, $t1, 1
condit:	
	blt $t1, $a1, looop
	jr $ra

### insertion sort
## $a0 pointer to array
## $v0 array size

insertsort:
	addi $t7, $0, 0		## variable a
	addi $t8, $0, 0		## temp
	addi $t9, $0, 1		## variable b
	move $a2, $a1
	j cont		
cont:
	bge $t9, $a2, end
	add $t7, $0, $t9	# a = b
	sll $t4, $t9, 2		# $t4 = b*4
	add $t4, $t4, $a0	# $t4 base address a[0]
	lw $t8, 0($t4)		#
	j while
while:
	blt $t7, $0, done	# if a<0 then sort is done
	sll $t5, $t7, 2		# 
	add $t5, $t5, $a0
	lw $t6, -4($t5)		#load value with offset
	blt $t6, $t8, done	# branch
	sw $t6, 0($t5)
	addi $t7, $t7, -1	#increment downward
	j while
		
done:
	sw $t8, 0($t5)
	addi $t9, $t9, 1
	j cont	
end:	jr $ra





