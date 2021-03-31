# HW1
# Kiara Madeam
# This program will prompt the user for their name and 3 integers
# then it will calculate/display the answer to three different equations

	.data
a:	.word	0
b:	.word	0
c:	.word	0
ans1:	.word	0
ans2:	.word	0
ans3:	.word	0

name:	.space	20

qname:	.asciiz	"What is your name: "
prompt:	.asciiz	"Please enter an integer between 1-100: "
final:	.asciiz	"Your answers are: "

	.text
main:
	# prompt user for name
	la	$a0,	qname
	li	$v0,	4
	syscall
	
	# input name
	li	$v0,	8
	li	$a1,	19
	la	$a0,	name
	syscall
	
	# prompt user for integer 1-100 (x3)-> read/store ints
	la	$a0,	prompt
	li	$v0,	4
	syscall
	li	$v0,	5
	syscall
	sw	$v0,	a	# first integer
	
	la	$a0,	prompt
	li	$v0,	4
	syscall
	li	$v0,	5
	syscall
	sw	$v0,	b	# second integer
	
	la	$a0,	prompt
	li	$v0,	4
	syscall
	li	$v0,	5
	syscall
	sw	$v0,	c	# third integer

	# store integers for calculations

	lw	$s1, a
	lw	$s2, b
	lw	$s3, c
	
	# calc ans1 = (a+a) - c + 4 and store
	add	$t1, $s1, $s1	# a+a
	sub	$t2, $t1, $s3	# 2a-c
	addi	$s4, $t2, 4	# 2a-c+4
	sw	$s4, ans1
	
	# calc ans2 = b - c + (a-2) and store
	
	addi	$t3, $s1, -2	# a-2
	sub	$t4, $s2, $s3	# b-c
	add	$s5, $t4, $t3	# b-c+(a-2) 
	sw	$s5, ans2
	
	# calc ans3 = (a+3) - (b-1) + (c+3) and store
	
	addi	$t5, $s1, 3	# a+3
	addi	$t6, $s2, -1	# b-1
	addi	$t7, $s3, 3	# c+3
	sub	$t8, $t5, $t6	# (a+3) - (b-1)
	add	$s6, $t8, $t7	# (a+3) - (b-1) + (c+3)
	sw	$s6, ans3
	
	# display name and final mssg
	la	$a0,	name
	li	$v0,	4
	syscall

	la	$a0,	final
	li	$v0,	4
	syscall
	
	# display results with space in between
	
	lw	$a0,	ans1	# display ans1
	li	$v0,	1
	syscall	
	
	la	$a0,	32	# display space
	li	$v0,	11
	syscall
	
	lw	$a0,	ans2	# display ans2
	li	$v0,	1
	syscall	
	
	la	$a0,	32	# display space
	li	$v0,	11
	syscall
	
	lw	$a0,	ans3	# display ans3
	li	$v0,	1
	syscall
	
	# exit program
exit:	li	$v0, 10
	syscall
	
############### Outputs ###############

# What is your name: Kiara
# Please enter an integer between 1-100: 2
# Please enter an integer between 1-100: 16
# Please enter an integer between 1-100: 81
# Kiara
# Your answers are: -73 -65 74
# -- program is finished running --

# What is your name: Kiara
# Please enter an integer between 1-100: 25
# Please enter an integer between 1-100: 33
# Please enter an integer between 1-100: 72
# Kiara
# Your answers are: -18 -16 71
# -- program is finished running --

# What is your name: Kiara
# Please enter an integer between 1-100: 10
# Please enter an integer between 1-100: 20
# Please enter an integer between 1-100: 30
# Kiara
# Your answers are: -6 -2 27
# -- program is finished running --
