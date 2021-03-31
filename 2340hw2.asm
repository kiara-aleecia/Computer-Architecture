# HW2
# Kiara Madeam
# This program will take a string from the user, count the number of words and
# characters in it, then tell the user these integers and repeat until the user
# enters an empty string. It will say goodbye before the program ends.
	
	.data
nChar:	.word	0
nWor:	.word	0
nSpa:	.word	0
length:	.word	150

uStr:	.space	150

greet:	.asciiz "Please type a message: "
wrds:	.asciiz	" words "
chrs:	.asciiz " characters\n"
bye:	.asciiz "See you later, alligator:)"

	.text
main:
	# prompt user for message
prompt:	la	$a0,	greet
	la	$a1,	uStr
	lw	$a2,	length
	li	$v0,	54
	syscall
	
	# check if cancel or blank
	beq	$a1, 	-2,	end
	beq	$a1, 	-3,	end
	
	# call function to count chars/words in str
	la	$a0,	uStr
	lw	$a1,	length
	jal count
	
	sw	$v0,	nChar
	sw	$v1,	nWor
	
	# display results
	la	$a0,	uStr
	li	$v0,	4
	syscall
	
	lw	$a0,	nWor
	li	$v0,	1
	syscall
	
	la	$a0,	wrds
	li	$v0,	4
	syscall
	
	lw	$a0,	nChar
	li	$v0,	1
	syscall
	
	la	$a0,	chrs
	li	$v0,	4
	syscall
	
	# goes back to start of prompt block
	j	prompt
	
end:	la	$a0,	bye
	li	$v0,	59
	syscall
	
	# exit program
exit:	li	$v0,	10
	syscall

########################################

# gets nChar and nWor then returns in $v0 and $v1
# also push/pop $s1 to and from the stack
count:	# push $s1 on stack (uStr)
	addi 	$sp,	 $sp,	-4
	sw	$s1,	($sp)
	move 	$s1, 	 $a0
	
	li	$t0,	0
	li	$t1,	1
	
# counts the # of chars/words
loop:	lb	$t2,	($s1)
	
	# stops counting when it gets to null/newline
	beq	$t2,	'\0',	return
	beq	$t2,	'\n',	return
	
	# increment char and word count
	addi	$t0,	$t0,	1	
	beq	$t2,	' ',	addWord
	j	next
	
# increments word count
addWord:
	addi	$t1,	$t1, 	1
	
# increments uStr
next:	
	addi	$s1,	$s1,	1
	j	loop
	
return:	# pop $s1 off stack
	lw	$s1,	($sp)
	add	$sp,	 $sp,	4
	
	# return values
	move	$v1,	$t1
	move	$v0,	$t0
	jr	$ra
