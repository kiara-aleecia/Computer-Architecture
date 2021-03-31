# Kiara Madeam "hw5macros.asm"
# Macros for 2340hw5.asm

# print_int -> print_int(4 or $t0)
.macro print_int (%x)
    li	$v0,	1
    add	$a0,	$zero, %x
    syscall
.end_macro


# print_str -> print_str("string in quotes (string literal)")
.macro print_str (%str)
    .data
str:.asciiz %str

    .text
    la	$a0,	str
    li	$v0,	4
    syscall
.end_macro


# print_strMem -> print_strMem(string label)
.macro print_strMem (%label)
    .text
    la	$a0,	%label
    li	$v0,	4
    syscall
.end_macro


# print_strReg -> print_strReg(string register)
.macro print_strReg (%r)
    .text
    move $a0,	%r
    li	 $v0,	4
    syscall
.end_macro


# print char -> print_char(char)
.macro print_char (%c)
    .data
c:  .byte %c

    .text
   lb	$a0,	c
   li 	$v0,	11
   syscall
.end_macro

# print_charLoop -> print_charLoop(char, number of chars)
.macro print_charLoop (%char, %count)
    addi $sp,	$sp,	-4	# offset return address
    sw	 $a0,	($sp)       	# $a0 to stack
  
    move $t8,	%count
    
printLoop:   
    beqz $t8,	endCharLoop	# if $t8 = 0 -> end printing char macro
    
    move $a0,	%char		# print char
    li   $v0,	11
    syscall
    
    addi $t8,	$t8,	-1	# loop until $t8 is down to zero
    j	printLoop
    
endCharLoop:
    lw	 $a0,	($sp)		# load return address from stack
    addi $sp,	$sp,	4
.end_macro


# for input string -> get_str(address, space)
.macro get_str (%x, %d)
   .text
   la	$a0,	%x
   li	$a1,	%d
   li	$v0,	8
   syscall
.end_macro


# open file -> open_file(string)
.macro open_file (%name)
    nl_null(%name)	  # call newline to null macro
   
    la	$a0,	%name
    li	$a1,	0
    li	$v0,	13
    syscall
   
    move $s0,	$v0       # usable file descriptor
    bgtz $v0,	openEnd
   
    print_str("Oops! Error reading file, program terminated...")
    j	exit
   
openEnd:
.end_macro


# accounts for newline in file names -> nl_null(string)
.macro	nl_null (%s)
    la	 $a0,	%s
    li	 $t0,	10		# newline
   
byteByByte:   
    lb	 $s1,	($a0)		# lb beginning of string
    beq	 $s1,	$t0,	end	# if equal to newline
    beqz $s1,	end		# if equal to null terminator
    addi $a0,	$a0,	1	# next byte
    j	 byteByByte
    
end:   
    sb	$zero,	($a0)		# set current byte to null
.end_macro


# read file -> read_file(address of buffer space for file)
.macro read_file (%buffer)
    move	$a0,	$s0	# move file descriptor to $a0
    la	$a1,	%buffer		# address of buff space
    li	$a2,	1024		# size of buff
    li 	$v0,	14
    syscall
    
    move	$s2,	$v0	# file size
.end_macro

# close file -> close_file
.macro close_file
    move $a0,	$s0		# file descriptor to $a0
    li	 $v0,	16  
    syscall
.end_macro

# dynamic memory -> heap_malloc(heap)
.macro heap_malloc (%mem_address)
    # allocate heap memory
    li	$a0,	1024
    li	$v0,	9
    syscall
   
    sw 	$v0,	%mem_address
.end_macro
