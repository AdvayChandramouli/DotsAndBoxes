.eqv COLMAX 17
.eqv ROWMAX 13


.text
computer_num:
	# Generate Random number for the X coordinate
    	li $v0, 42
	la $a1, COLMAX
	syscall 
	move $t0, $a0
	
	# Generate Random Number for the Y coordinate
	la $a1, ROWMAX
	syscall
	move $t1, $a0
	
	# Moves the final numbers into $v0, $v1 register so that they can be used by the other functions
	move $v0, $t0
	move $v1, $t1        

	jr $ra
