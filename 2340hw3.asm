# HW3
# Kiara Madeam
# This program will read integers in from a file and
# store them in an array. Then it will sort it using
# the selection sort algorithm and print. Finally it
# will calculate/print the mean, median, and standard
# deviation of the set of integers.
	
	.data
nums:	.word	0

fName:	.asciiz	"input.txt"
	.align	2

buff:	.space	80
array:	.space	80

mssg1:	.asciiz "The array before:\t"
mssg2:	.asciiz "\nThe array after:\t"
mssg3:	.asciiz	"\nThe mean is: "
mssg4:	.asciiz	"\nThe median is: "
mssg5:	.asciiz "\nThe standard deviation is: "
mssg6:	.asciiz "Oops! Error reading file, program terminated..."

	.text
main:
	# open input file & call read input funct
	la	$a0, fName
	la	$a1, buff
	jal readI
	
	# call funct for string -> int
	la	$a0, array
	li	$a1, 20
	la	$a2, buff
	jal	extract
	
	# num of elements -> $t6
	move 	$t6, $v0
	
	# print array before sort mssg
	la	$a0,	mssg1
	li	$v0,	4
	syscall
	
	# call funct for printing array ints (1)
	la	$a0, array
	move	$a1, $t6
	jal	print
	
	# call function for selection sort
	la	$a0, array
	move	$a1, $t6
	jal	sort
	
	# print array after sort mssg
	la	$a0,	mssg2
	li	$v0,	4
	syscall
	
	# call funct for printing array ints (2)
	la	$a0, array
	move	$a1, $t6
	jal	print
	
	# print mean mssg
	la	$a0,	mssg3
	li	$v0,	4
	syscall
	
	# call funct for calculating mean
	la	$a0, array
	move	$a1, $t6
	jal	mean
	
	# print mean
	li	$v0, 2
	syscall
	
	# print median mssg
	la	$a0,	mssg4
	li	$v0,	4
	syscall
	
	# call funct for calculating median
	la	$a0, array
	move	$a1, $t6
	jal	median
	
	# $v1 < 0 mean -> median is float (avg two mid numbers)
	li	$t7, 0
	blt	$v1, $t7, pFloat
	
	# $v1 > 0 mean -> median is integer (middle numbers)
	move	$a0, $v0
	
	# print median
	li	$v0, 1
	syscall
	
	j	SD
	
	# print float (median)
pFloat:
	li	$v0, 2
	syscall
	
	# standard deviation tasks
SD:
	# print SD message
	la	$a0,	mssg5
	li	$v0,	4
	syscall
	
	# call funct for calculating SD
	la	$a0, array
	move	$a1, $t6
	jal	stanDev
	
	# print SD
	li	$v0, 2
	syscall
	
	# exit program
exit:	li	$v0,	10
	syscall
	
###################################################

	# reads data from input
readI:	
	move	$t0, $a1	# move buff address to $t0

	li	$a1, 0		# read from file flag
	li	$v0, 13
	syscall
	
	blt	$v0, $0, error	# display error mssg if file didn't work
	
	move	$s0, $v0	# save file descriptor in $s0

	move	$a0, $s0	# file address
	move	$a1, $t0	# buff address
	li	$a2, 80		# buff length
	li	$v0, 14
	syscall

	move	$s2, $v0	# return characters read
	
	# close file
	move	$a0, $s0
	li	$v0, 16
	syscall
	
	jr	$ra
	
###################################################

	# read buff byte by byte (string -> int)
extract:
	li	$t0, 0
	li	$s1, -1
	
store:
	lb	$t1, ($a2)	  # buff address in $t1
	beq	$t1, $0, endExtr  # end of file
	beq	$t1, 10, storeInt # newline -> store as number
	
	# ignore ifs (must be 0-9)
	bgt	$t1, 57, ignore	  # $t1 > 57 (9)
	blt	$t1, 48, ignore	  # $t1 < 48 (0)
	
	addi	$t1, $t1, -48	# convert ASCII -> int
	
	bne	$s1, -1, mult10	# if first time/byte is start digit -> $s1 = 0
	li	$s1, 0		
	
mult10:
	li	$t2, 10
	mul	$s1, $s1, $t2	# $s1 * 10
	add	$s1, $s1, $t1	# (($s1 + 10) + $t1) ($t1 = buff address)
	
ignore:
	addi	$a2, $a2, 1	# buff address -> next byte
	j	store

storeInt:
	beq	$s1, -1, skip	# $s1 = -1 -> don't store int
	sll	$t3, $t0, 2	# counter * 4 (b/c word is 4 bytes)
	add	$t3, $t3, $a0	# go to correct spot in array & store int
	sw	$s1, ($t3)
	li	$s1, -1		# used for next int
	
skip:
	addi	$a2, $a2, 1	  # increment (byte)
	addi	$t0, $t0, 1	  # increment (counter)
	beq	$t0, 20, endExtr  # full array
	
	j	store
	
endExtr:
	move	$v0, $t0	# return # of elements (array length)
	jr	$ra
	
###################################################

	# print array elements with space in between
print:
	move	$s0, $a0	# array address
	li	$t0, 0		# new counter	
	
pLoop:	
	beq	$t0, $a1, endPrint  # stop printing at end of array
	
	sll	$t2, $t0, 2	    # counter * 4 (b/c word is 4 bytes)
	add	$t2, $t2, $s0	    # go to correct spot in array
	
	lw	$a0, ($t2)	# load int
	li	$v0, 1		# print int
	syscall
	
	la	$a0, 32		# print space
	li	$v0, 11
	syscall
	
	addi	$t0, $t0, 1	# counter++
	j	pLoop
	
endPrint:
	jr	$ra
	
###################################################
	
	# use selection sort to make array least -> greatest
sort:	
	addi	$s0, $a1, -1	# $s0 -> n - 1
	li	$t0, 0		# $t0 = j
	
outer:
	beq	$t0, $s0, endSort
	move	$s1, $t0	  # j -> smallest index
	addi	$t1, $t0, 1	  # j + 1 -> i

inner:
	beq	$t1, $a1, chkSwap # if elements equal -> swap
	
	sll	$t3, $s1, 2	  # j
	sll	$t2, $t1, 2	  # i
	
	add	$t3, $t3, $a0	  # find position of i/j in array
	add	$t2, $t2, $a0
	
	lw	$t5, ($t3)	  # $t5 = array[small]
	lw	$t4, ($t2)	  # $t4 = array[i]
	
	blt	$t4, $t5, newIndex # if $t0<$t1 -> swap $t0 & $t1
	j	toInner

newIndex:
	move	$s1, $t1	# small = i

toInner:
	addi	$t1, $t1, 1	# i++
	j	inner		# -> start again at inner
	
chkSwap:
	# array[j] <-> array[small] (when array[i]<array[small])
	bne	$t0, $s1, swap
	j	toOuter
	
swap:
	sll	$t3, $s1, 2
	sll	$t2, $t0, 2
	
	add	$t3, $t3, $a0
	add	$t2, $t2, $a0

	lw	$t5, ($t3)
	lw	$t4, ($t2)
	sw	$t5, ($t2)
	sw	$t4, ($t3)

toOuter:
	addi	$t0, $t0, 1
	j	outer		# -> start again at outer

endSort:
	jr	$ra

###################################################

	# returns mean of array
mean:
	li	$t0, 0
	mtc1	$t0, $f0
	mtc1	$t0, $f12	# sum tracker -> 0
	
sum:
	beq	$t0, $a1, endMean  # stops when $t0 = num elements
	sll	$t1, $t0, 2
	add	$t1, $t1, $a0
	
	lwc1	$f0, ($t1)	# load float (from int) into $f0	
	add.s	$f12, $f12, $f0	# add $f0 to $f12
	
	addi	$t0, $t0, 1	# counter++
	j	sum

endMean:
	mtc1	$a1, $f0	# n -> $f0
	div.s	$f12, $f12, $f0	# (sum/n) -> $f12 -> mean
	
	jr	$ra

###################################################

	# returns median of array
median:
	div	$t0, $a1, 2	# length / 2 -> middle index
	mfhi	$t1
	
	# $t1 != 0 -> num of elements is odd -> calc average
	beq	$t1, $0, average
	
	sll	$t2, $t0, 2
	add	$t2, $t2, $a0
	lw	$v0, ($t2)
	
	li $v1, 0		# if $v1 = 0 -> integer median
	j	endMedian
	
	# only execute this branch if odd num of elements
average:
	addi	$t1, $t0, 1
	
	sll	$t3, $t1, 2
	sll	$t2, $t0, 2
	
	add	$t3, $t3, $a0	# go to middle two spots in array
	add	$t2, $t2, $a0
	
	addi	$t2, $t2, -4
	addi	$t3, $t3, -4
	
	lw	$t5, ($t3)	# load middle two elements
	lw	$t4, ($t2)
	
	add	$t4, $t4, $t5	# middle + middle
	
	mtc1	$t4, $f12	# sum -> float
	
	li	$t5, 2
	mtc1	$t5, $f0	# 2 -> $f0
	div.s	$f12, $f12, $f0	# $f12 / 2
	
	li	$v1, -1		# if $v1 = -1 -> float median

endMedian:
	jr	$ra
	
###################################################

	# returns standard dev of array
stanDev:
	# go to calculate mean (w/ here as new return address)
	addi	$sp, $sp, -4	# offset return address
	sw	$ra, 4($sp)
	jal	mean
	
	mov.s	$f0, $f12	# mean ($f12) -> $f0
	li	$t0, 0
	mtc1	$t0, $f12	# sum = 0 ($f12 -> sum tracker)
	
calcStanDev:
	beq	$t0, $a1, endStanDev	# if $t0 = num elements -> main
	
	sll	$t1, $t0, 2
	
	add	$t1, $t1, $a0
	lw	$t2, ($t1)
	
	mtc1	$t2, $f1
	cvt.s.w	$f1, $f1	# single precision
	
	sub.s	$f2, $f1, $f0	# $f2 = r_i - r_avg
	mul.s	$f3, $f2, $f2	# $f3 = (r_i - r_avg)^2
	add.s	$f12, $f12, $f3	# $f12 = sigma ((r_i - r_avg)^2)
	
	addi	$t0, $t0, 1
	j	calcStanDev

endStanDev:
	addi	$t2, $a1, -1	# n - 1 -> $t3
	
	mtc1	$t2, $f4	# n - 1 -> float ($f4)
	cvt.s.w	$f4, $f4	# $f4 -> single precision
	div.s	$f12, $f12, $f4	# (sum / (n - 1)) -> sum ($f12)
	sqrt.s	$f12, $f12	# sqrt($f12) -> $f12
	
	lw	$ra, 4($sp)
	addi	$sp, $sp, 4	# go back to return address for SDCalc
	jr	$ra

###################################################

error:	
	la	$a0,	mssg6
	li	$v0,	4
	syscall
	j	exit
