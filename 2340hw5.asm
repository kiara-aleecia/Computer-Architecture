# Kiara Madeam HW5
# This program will use a compression algorithm to compress and
# uncompress a message read in from a file (hw5macros)

.include	"hw5macros.asm"

	.data
	
file:	.space	30
buff:	.space	1024
oSize:	.word	0	# original size
cSize:	.word	0	# compressed size
heap:	.word	0	# pointer to heap stuff

	.text
	
main:
	heap_malloc(heap)	# allocate dynamic mem
	
	print_str("Enter file name to compress or <enter> to exit: ")
	
	# get string from user
	la	$a0,	file
	li	$a1,	30
	li	$v0,	8
	syscall
	
	# check if <enter>
	lb	$t0,	($a0)
	beq	$t0,	10,	exit

	# open/read/close file
	open_file(file)
   	read_file(buff)
   	sw 	$s2,	oSize	# store file size

	# keeps prev. input from being displayed
    	la	$t1,	buff
    	add	$s2,	$s2,	$t1
    	sb	$zero,	($s2)
  
   	close_file

	# display file data
 	print_str("\nOriginal data:\n")
   	print_strMem(buff)

	print_str("\nCompressed data:\n")

   	la	$a0,	buff
   	lw	$a1,	oSize
   	lw	$a2,	heap	# dynamic mem address
   	jal	compress
  
  	# print compressed data stored in heap from $t7
   	lw 	$t7,	heap
   	print_strReg($t7)
   
	print_str("\nUncompressed data:\n")
  
	lw	$a0,	heap	# dynamic mem address
	lw	$a1,	oSize
	jal decompress
  
	print_str("\nOriginal file size: ")
	
	lw 	$a0,	oSize
	li 	$v0,	1
	syscall
  
   	print_str("\nCompressed file size: ")
   	
	lw 	$a0,	cSize
	li 	$v0,	1
	syscall
   
   	# newline to make next iteration look cleaner
   	print_char(10)
  
  	# loop to beginning
	j main
   
	# exit program
exit:	li	$v0,	10
	syscall
	
#####################################################

# compression RLE algorithm
compress:
	li 	$t0,	0       	# counter
	addi	$s3,	$a1,	-1      # $s3 = size - 1
	li 	$s4,	0		# for compressed size
	
outer:
	bge	$t0,	$a1,	endComp	# counter < size -> branch
	li	$t1,	1       	# charCount = 1
  
inner: 
	add 	$t2,	$t0,	$a0
	lb 	$s5,	($t2)		# pointer to byte
	addi	$t3,	$t0,	1
	add	$t3,	$t3,	$a0
	lb 	$s1,	($t3)		# pointer to next byte
  
  	# if counter >= size - 1 -> branch
   	bge	$t0,	$s3,	storeDyn
   	
   	# if s1 != s5 -> branch
	bne	$s1,	$s5,	storeDyn
	
	# increment char count and counter
	addi	$t0,	$t0,	1
   	addi 	$t1,	$t1,	1
   	
   	j inner
   
storeDyn:
	sb	$s5,	($a2)		# store byte
	
	addi	$s4,	$s4,	1
	addi	$a2,	$a2,	1     	# next heap place 
	
	#  if char count is > 9 -> branch
	bgt 	$t1,	9,	doubleDigit
  
	addi	$t1,	$t1,	48	# calc ascii val by adding 48
	sb	$t1,	($a2)		# store ascii val for char count
  
	addi	$s4,	$s4,	1       # increment compressed size
	addi	$a2,	$a2,	1       # get next heap location
	addi	$t0,	$t0,	1       # increment counter
	
	j	outer
   
doubleDigit:
	li	$t4,	10
   
	div 	$t1,	$t4
   
	mflo 	$t5			# ones place
	mfhi 	$t6			# tens place
   
	addi	$t5,	$t5,	48	# ones place ascii
	sb 	$t5,	($a2)		# store ones place ascii
   
	addi	$t6,	$t6,	48	# tens place ascii
	addi 	$a2,	$a2,	1	# get next heap location
	sb 	$t6,	($a2)		# store tens place ascii
   
	addi 	$a2,	$a2,	1       # get next heap location
	addi 	$t0,	$t0,	1       # increment counter
	
	addi 	$s4,	$s4,	1       # inc compressed size
  
	j	outer
   
endComp:
	sw 	$s4,	cSize		# store compressed size
   	jr	$ra  
  
#####################################################

# decompression RLE algorithm
decompress:
	li	$t9,	10
   
loadData:
	lb	$t0,	($a0)			# load compressed data
	lb	$t1,	1($a0)
	lb	$t2,	2($a0)
  
	beqz	$a1,	endDecomp		# if size = 0 -> end
	
	blt 	$t2,	48,	oneDigit	# check digits w/ ascii vals
	ble	$t2,	57,	twoDigits
  
oneDigit:
	addi	$t1,	$t1,	-48   		# convert val from ascii
   	print_charLoop($t0, $t1)		# print chars
   	sub	$a1,	$a1,	$t1		# subtract val from size
	addi	$a0,	$a0,	2		# go to next char
	j	loadData

twoDigits:
	addi	$t1,	$t1,	-48		# convert both vals from ascii
	addi 	$t2,	$t2,	-48
			
	mul	$t1,	$t1,	$t9		# tens
	add	$t1,	$t1,	$t2		# calc two digit count
  
	print_charLoop($t0,$t1)			# print chars
	
	sub	$a1,	$a1,	$t1		# subtract val from size
	addi	$a0,	$a0,	3		# go to next char
	j	loadData
  
endDecomp:
	jr	$ra
