# John Enquist final project for comporg
# making a binary heap data type

## System calls
PR_INT = 1
	.data
PR_STR = 4	
	.data
comma:
	.asciiz ", "
	.text
	.data

str:
	.asciiz "binary heap = "
	.text
	.data

newline:
	.asciiz "\n"
	.text
	.data
## Node structure
DATA     = 0                    ## value at index
NODESIZE = 4    	        ## size of node
NUMNODES = 15           
HEAPSIZE = 60 	       	             ##NODESIZE*NUMNODES = 15 spaces for heap
NIL      = 0                         ## for null pointer

        .data
input: .word 5, 4, 9, 7, 6, 1, 3, 3, 3, 2 ## you add more numbers here  (no more than NUMNODES)
inp_end:
INSIZE = 10 #(inp_end - input)/4    # number of input array elements

heap:   .space  HEAPSIZE           # storage for nodes 
spce:   .asciiz " "
nofree: .asciiz "Out of free nodes; terminating program\n"

        .align 2
        .text
main:   addi $sp, $sp, -4
        sw $ra, 0($sp)
        li $s7, NIL             # global variable holding the NIL value
	la $a0, input		# putting array in a0
	la $a1, heap		# puts heap address in a1
	la $a2, INSIZE 		# size of array 
	jal buildheap		# build the heap from the array

	jal print		# prints the heap

#	addi $t0, $0, 2		# number to find is 2
#	move $a0, $t0		# set up parameter for find
#	jal find		# finds 8 and returns 1 if there else 0
	
	jal delmin		# deletes top element (1) and stores it in $s1
	jal print

	addi $t0, $0, 1		# number to insert is 4
	move $a0, $t0		# parameter for insert set up
	jal insert		# inserts 1 and balances the heap accordingly
	jal print
	
	lw $ra 0($sp)		# get return address back
	addi $sp, $sp, 4	# restore stack
	jr $ra			# end


#inputs: $a0 = an unsorted array
#	 $a1 = heap space pointer
#	 $a2 = size of the array	
#outputs: $v0 = a pointer to a heap of the arrays data
#	  $v1 = size of the heap
buildheap:	
	move $t0, $a2		# puts length of list in $t0
	sra $t1, $t0, 1		# puts lengthOfList/2 in $t1
	addi $sp, $sp, -4	# push onto stack
	sw $ra, 0($sp)		# return address
	move $t4, $a1		# storing pointer to heap in $t4
	
	addi $t2, $0, 0		# initialize counter i
a:	lw $t3, 0($a0)		# get element i from the array in $t3
	sw $t3, 0($a1)		# and store it in space i in the heap
	addi $t2, $t2, 1	# increment counter
	addi $a0, $a0, 4	# increment pointer to array
	addi $a1, $a1, 4	# increment pointer to heap
	bne $t0, $t2, a		# loop until you reach the end of the array
	move $a0, $t1		# put i in $a0
	move $a1, $t4		# a1 now has heap address
	move $a2, $a2		# $a2 is now the size of the heap
	
heapi:  jal percdown		# heapify for index i (hey that rhymes)
	addi $a0, $a0, -1	# i = i - 1
	bne $a0, $s7, heapi	# while i > 0, loop
	
fin:	move $v0, $t4		# returns a pointer to the heap
	move $v1, $a2		# saves the size of the heap in $s0
	lw $ra, 0($sp)		# get return address back
	addi $sp, $sp, 4	# restore stack
	jr $ra			# return

#inputs: $a0 = i
#	 $a1 = a pointer to the heap
#	 $a2 = size of heap	
#outputs: nothing
percdown:
	addi $sp, $sp, -8	# push onto stack
	sw $ra, 0($sp)		# return address
	sw $a0, 4($sp)		# i counter for buildheap
	move $t0, $a0		# put i into $t0
while:	sll $t0, $t0, 1		# i = i*2
	bgt $t0, $a2, end	# if i*2 > heapsize, jump to end
## $a0 should never change across minchild and percdown so i shouldnt need to reinstantiate it
	jal minchild		# puts the index of the minchild of i in $vo
	move $t1, $v0		# puts minchild index in $t1
	move $t2, $a0		# get index i in $t2
	sll $t1, $t1, 2		# get byte address of minchild
	sll $t2, $t2, 2		# get byte address of i
	la $t3, 0($a1)		# get address of heap in $t3
	sub $t3, $t3, 4		# go back one
	add $t1, $t1, $t3	# get address of minchild  *****make sure these are right
	add $t2, $t2, $t3	# get address of i  ******
	lw $t4, 0($t1)		# get value of minchild
	lw $t5, 0($t2)		# get value of i
	bgt $t5, $t4, swap	# if parent is bigger than child, swap
	j con			# jump to con without swapping
swap:	sw $t4, 0($t2)		# swap minchild into parent index i
	sw $t5, 0($t1)		# swap i with minchild

con:	move $t0, $v0		# put minchild index in $t0
	move $a0, $v0		# add in new index for when moving down a child again
	j while			# continue looping to balancing is over
	
end:	lw $ra, 0($sp)		# get back return address
	lw $a0, 4($sp)		# get back $a0
	addi $sp, $sp, 8	# restore stack
	jr $ra			# return when loop condition is done
	
##works
#inputs: $a2 = size of heap
# 	 $a1 = a pointer to the heap
#	 $a0 = i (index of node)
#outputs:$v0 = minchild of the 2 children of node i 	
minchild:	
	move $t0, $a0		# put i into $t0
	sll $t0, $t0, 1		# i = i*2
	addi $t0, $t0, 1	# i = i*2 + 1 (aka left child index of node i)
	move $t6, $t0		# move i*2+1 into t6 for safekeeping
	bgt $t0, $a2, c		# if right child is past size of the heap, look back one
	sll $t0, $t0, 2		# i = i*4 for byte address in heap
	la $t2, 0($a1)		# put heap pointer in $t2
	add $t2, $t2, $t0	# $t2 now points to heap[i*2+2]***
	sub $t3, $t2, 4		# $t3 no points to heap[i*2+1]***
	lw $t1, 0($t3)		# get h[i*2+1]
	sub $t3, $t3, 4		# switch pointer to h[i*2]
	lw $t4, 0($t3)		# get h[i*2]
	slt $t5, $t1, $t4	# t5=1 if t1 < t4
	bne $t5, $s7, ret	# jump to ret	
c:	addi $t6, $t6, -1	# get i*2
	move $v0, $t6		# put i*2 in return address
	jr $ra
ret:	move $v0, $t6		# put i*2+1 in return address
	jr $ra			

# inputs: $a1 = heap pointer
#	  $a2 = size of the heap
# outputs:$v0 = min item removed (root of heap)	
delmin:
	addi $sp, $sp, -4	# push onto stack
	sw $ra, 0($sp)		# return address
	lw $t4, 0($a1)		# return value of root
	move $s1, $t4		# load the last removed element in $s1
	move $t0, $a2		# get heap size in $t0
	sll $t0, $t0, 2		# get byte address of last element in heap
	sub $t0, $t0, 4		# proper address***
	la $t1, 0($a1)		# get get heap address in $t1
	add $t1, $t1, $t0	# get correct address
	lw $t2, 0($t1)		# get last element in heap
	sw $t2, 0($a1)		# replace first element with last element
	addi $a2, $a2, -1	# decrease heap size by 1
	addi $a0, $0, 1		# put 1 in $a0 for percdown
	# **/ $a1 still points to heap \** #
	jal percdown		# reheap from the top
	lw $ra, 0($sp)		# get back return address
	addi $sp, $sp, 4	# restore stack
	jr $ra			# return


# inputs: $a0 = a number to insert
#	  $a1 = pointer to heap
#	  $a2 = size of the heap
# outputs: none
insert:
	addi $sp, $sp, -4	# push onto stack
	sw $ra, 0($sp)		# return address
	addi $a2, $a2, 1	# increase size of heap by 1
	la $t0, 0($a1)		# get heap address in $t0
	sub $t0, $t0, 4		# get to index 0
	sll $t1, $a2, 2		# get byte address for end of heap
	add $t1, $t1, $t0	# get address in heap for last element
	sw $a0, 0($t1)		# add new number to the end of the heap
	jal percup		# all the a registers should be right!
	lw $ra, 0($sp)		# get back return address
	addi $sp, $sp, 4	# restore stack
	jr $ra
	 
	
	

	
# inputs: $a1 = pointer to heap	
# 	  $a2 = size of the heap
# outputs: none
percup:
	move $t0, $a2		# move i into $t0
	addi $t1, $0, 2		# put 2 in $t1
loop:	div $t0, $t1		# i/2 where the quotient is stored in $HI
	mflo $t2 		# put quotient in $t2
	beq $t2, $s7, en	# if i/2 is equal to 0, branch to end
	la $t3, 0($a1)		# put heap address in $t3
	sub $t3, $t3, 4		# take off 4 bytes for index 0
	move $t4, $t0		# get back i again
	sll $t4, $t4, 2		# get byte address for i
	sll $t2, $t2, 2		# get byte address for parent of i
	add $t4, $t4, $t3	# get proper address for i
	add $t2, $t2, $t3	# get proper address for parent of i
	lw $t6, 0($t4)		# get value of i
	lw $t7, 0($t2)		# get value of parent of i
	slt $t5, $t7, $t6	# if parent is less than child, $t5 = 1
	bne $t5, $s7, next	# dont swap if parent is less than child
	sw $t6, 0($t2)		# swap values
	sw $t7, 0($t4)		# swap values
next:	mflo $t0 		# i/2 should still be in $HI
	j loop
	
en:	jr $ra			# return

# inputs: $a0 = number to find
#         $a1 = pointer to heap	
# 	  $a2 = size of the heap
# outputs: $v0 = 1 if element is in list, 0 otherwise
find:
	addi $t0, $0, 1		# initialize counter k
	la $t1, 0($a1)		# put heap address in $t1
	sub $t1, $t1, 4		# move back one for counter
nex:	bgt $t0, $a2, notfnd    # if counter reaches the end of the heap, branch
	sll $t4, $t0, 2		# multiply index k by for to get byte address
	add $t2, $t1, $t4	# get index for element k
	lw $t3, 0($t2)		# get number at index k
	addi $t0, $t0, 1	# increment counter by 1
	bne $t3, $a0, nex	# if element k is not a0, repeat
	addi $v0, $0, 1		# return 1
	jr $ra			# return
notfnd:	addi $v0, $0, 0		# not found, returning 0
	jr $ra

# inputs: $a1 = pointer to heap	
#	  $a2 = size of heap
# outputs: prints the heap
print:
	la $t1, 0($a1)		# get heap index in $t1
	sll $t3, $a2, 2		# get byte length of heap
	sub $t3, $t3, 4		# get proper end of heap
	add $t2, $t1, $t3	# full length of heap add
	li $v0, PR_STR		# adding data to print
	la $a0, str		# adding comma to print
	syscall

loot:	lw $t0, 0($t1)		# get element of heap
	li $v0 PR_INT		# print an int
	move $a0, $t0		# get number to print
	syscall
	addi $t1, $t1, 4	# increment index
	li $v0, PR_STR		# adding data to print
	la $a0, comma		# adding comma to print
	syscall
	bgt $t2, $t1, loot	# while counter != size, loop
	lw $t0, 0($t1)		# get element of heap
	li $v0 PR_INT		# print an int
	move $a0, $t0		# get number to print
	syscall
	li $v0, PR_STR		# adding data to print
	la $a0, newline		# adding comma to print
	syscall
	jr $ra
	
