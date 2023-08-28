.include "inputValidationn.asm"
.include "countboxes.asm"
.include "comp.asm"

.eqv COLMAX 17
.eqv ROWMAX 13

.data
enter:		.asciiz "\n"
introMess:	.asciiz "\nLet's play dots and boxes! :) \nEnter coordinates to add a line\n"
x_prompt:	.asciiz "\nEnter x coordinate: "
y_prompt:	.asciiz "Enter y coordinate: "
inval_prompt:	.asciiz "Invalid input, try again\n"

computer_play_prompt: .asciiz "Computer play\n"

.text
.globl main
main:
	# print intro message
	la $a0, introMess 
	li $v0, 4 
	syscall  
	
	# allocate 2D array
	li $s1, ROWMAX		# number of rows
	li $s2, COLMAX		# number of columns
	mul $a0, $s1, $s2	# multiply row x columns to get total amount of space needed
	li  $v0, 9
	syscall
	
	move $s0,$v0   		# save array address in $s0
	jal make_array		# creates dot chart
	
start_game:	
	jal print_array
	
	jal printScore
	bne $v0,$zero, end_program	# if turn counter = total number of turns, end program
	
	li $t6, 0
	j get_user_coord		# ask user for coordinates
	
	cmp:
	jal print_array
	move $a0,$t0
	move $a1,$t1
	move $a2,$t6
	jal countBox
	
	la $a0, computer_play_prompt 
	li $v0, 4 
	syscall 
	 
	# call computer to play here
	
	li $t6,1
	j get_comp
	t:
	jal add_line
	move $a0,$t0
	move $a1,$t1
	move $a2,$t6
	jal countBox
	
	j start_game

########################################################################

# puts dots and spaces into array	
make_array:
	li $t3, 0	# initialize outer-loop counter to 0
outer_loop:
	bge $t3,$s1,outer_loop_end	# if outer-loop counter >= columns, branch
	li $t4,0			# initialize inner-loop counter to 0
	beqz $t3,inner_loop_even	# if $t3 = 0, branch
	
	andi $t2, $t3, 0x01		# and
	beq $t2, $zero, inner_loop_even	# if $t3 is even
	b inner_loop_odd		# if $t3 is odd and not 0
	
inner_loop_even:
	bge $t4,$s2,inner_loop_end	# if inner-loop counter >= rows, branch
	
	#calculate address
	mul $t5,$t3,$s2			# $t5 = outer-loop counter * rows
	add $t5,$t5,$t4			# $t5 = (outer-loop counter * row) + inner-loop counter
	add $t5,$s0,$t5			# $t5 = base address + (outer-loop counter * width + inner-loop counter)
	
	# tests if inner loop counter is even or 0
	beqz $t4,load_dot		# if $t4 = 0, branch to load_dot
	andi $t2, $t4, 0x01		
	beq $t2, $zero, load_dot	# if $t4 is even, branch to load_dot
	
	# load space if loop counter is odd and > 0
	#lb $a0,space
	li $a0,' '
	sb $a0,0($t5)
	b inner_loop_next
	
	load_dot:
	#lb $a0,dot			# load dot into $a0
	li $a0,'.'
	sb $a0,0($t5)			# store byte into array
	b inner_loop_next
	
	inner_loop_next:
	addiu $t4,$t4, 1		# increment inner loop
	b inner_loop_even
	
inner_loop_odd:
	bge $t4,$s2,inner_loop_end	# if inner-loop counter >= rows, branch
	
	mul $t5,$t3,$s2			# $t5 = outer-loop counter * rows
	add $t5,$t5,$t4			# $t5 = (outer-loop counter * row) + inner-loop counter
	add $t5,$s0,$t5			# $t5 = base address + (outer-loop counter * width + inner-loop counter)
	
	# load space into array
	#lb $a0,space
	li $a0,' '
	sb $a0,0($t5)
	
	addiu $t4,$t4, 1		# increment inner loop
	b inner_loop_odd
	
inner_loop_end:
	addiu $t3,$t3,1			# increment outer loop by 1
	
	b outer_loop
outer_loop_end: jr $ra
		#j start_game

########################################################################

# loop to print array
print_array:
	li $t3, 0	# initialize outer-loop counter to 0
o_loop:
	bge $t3,$s1,o_loop_end	# if outer-loop counter >= columns, branch
	li $t4,0			# initialize inner-loop counter to 0
i_loop:
	bge $t4,$s2,i_loop_end	# if inner-loop counter >= rows, branch
	
	mul $t5,$t3,$s2			# $t5 = outer-loop counter * rows
	add $t5,$t5,$t4			# $t5 = (outer-loop counter * row) + inner-loop counter
	add $t5,$s0,$t5			# $t5 = base address + (outer-loop counter * width + inner-loop counter)
	
	# print element in array
	lb $a0,0($t5)			# load contents of element into $a0
	li $v0, 11 			
	syscall
	
	# print space
	li $a0, 32
    	li $v0, 11  
    	syscall
	
	addiu $t4,$t4, 1		# increment inner loop
	b i_loop			# returnt to beginning of inner loop
i_loop_end:				
	addiu $t3,$t3,1			# increment outer loop by 1
	
	la $a0, enter 			# print newline
	li $v0, 4 
	syscall
	
	b o_loop			# branch to beginning of outer loop
o_loop_end:	jr $ra			# return once outer loop has ended

########################################################################

# get coordinates from user
get_user_coord:	
	# prompt user for x coordinate
	la $a0,x_prompt		# print prompt
	li $v0, 4 
	syscall 
	
	li $v0, 5		# collects user input
	syscall
	add $t0, $v0, $zero	#put x coordinate into $s3
	
	# prompt user for y coordinate
	la $a0,y_prompt		# print prompt
	li $v0, 4 
	syscall
	
	li $v0, 5		# collects user input
	syscall
	add $t1, $v0, $zero	# put y coordinate into $t1
	
	# call input validation
	jal inputValidation
	
	
	#jal  add_line
	jal add_line
	j cmp

########################################################################

# call computer to play
get_comp:
	jal computer_num
	move $t0,$v0
	move $t1,$v1
	
	jal inputValidation
	
	beq $t3, 0, get_comp		# if invalid do not increment
	
	b t
	

########################################################################
# add line to array
add_line:
	
	#calculate address + put into $t0
	mul $t5,$t1,$s2			# $t5 = y * rows
	add $t5,$t5,$t0			# $t5 = (y * row) + x
	add $t5,$s0,$t5			# $t5 = base address + (y * width + x)
	
	# test x = 0 or x is even
	#beqz $t0,add_vLine		# if x = 0, branch to add_vLine
	#andi $t2, $t0, 0x01		
	#beq $t2, $zero, add_vLine	# if x is even, branch to add_vLine
	#b add_hLine			# otherwise, branch to add_hLine
	
	beq $t3,2,add_vLine
	beq $t3,1, add_hLine
	beq $t3,0, invalid
	
	# adds vertical line to array
	add_vLine:
	#lb $a0,vLine			# load "|" into $a0
	li $a0,'|'
	sb $a0,0($t5)			# store byte into array
	b add_exit			
	
	# adds horizontal line to array
	add_hLine:
	#lb $a0,hLine			# load "-" into $a0
	li $a0,'-'
	sb $a0,0($t5)
	b add_exit
	
	invalid:
	la $a0, inval_prompt 
	li $v0, 4 
	syscall 
	b get_user_coord
	
	add_exit:
	
	
	addi $s6,$s6,1			# count number of terms
	
	jr $ra			# go back to start

########################################################################

# end program
end_program:	
	li $v0, 10		#end program
	syscall
