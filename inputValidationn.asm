.data

array: .space 440   # allocate space for 110 integers
arrayCounter: .word 0


.text
#main:	
	
	
inputValidation:

	
	#array declaration for loading the array that will store the played coordinates 
	lw $s3, arrayCounter 
	la $s7, array
	addi $s4, $s7, 0
	addi $s5, $s7, 0
	li $t4, 0
	li $t7, 0
	li $t3, 0
    	
	
	# Check if row and column are within bounds
	bltz $t0, out_of_bounds   # branch if row < 0
	li $t2, 16                # maximum row
	bgt $t0, $t2, out_of_bounds   # branch if row > 12
	bltz $t1, out_of_bounds   # branch if column < 0
	li $t2, 12              # maximum column
	bgt $t1, $t2, out_of_bounds   # branch if column > 16
	
	
	rem $t8, $t1, 2		#getting the remainder of the column
	
	beq $t8, $zero, column_is_even	#if the remainder is zero, go to column is even
	backHere:
	bgt $t8, $zero, check_row	#if the remainder is > zero, got to check row
	
	add $t3,$t3,$zero	#adding zero to $t3

singleDigit:
	bgt $t0, 9, doubleDigit	   #if it is a double number aka >9, branch to double digits
	# Concatenate row and column to form an integer
	li $v0, 0       # initialize $v0 to 0
	mul $t0, $t0 ,10    # multiply row by 10
	mflo $v1        # save the result in $v1
	add $v0, $v0, $v1   # add row to $v0
	add $v0, $v0, $t1  # add column to $v0
	move $t3, $v0        # save the concatenated integer in $t3
	div $t0, $t0, 10	#dividing to retain the original value 
	j next		#jump to next

#for double digits 
doubleDigit:
	li $v0, 0       # initialize $v0 to 0
	mul $t0, $t0 ,100    # multiply row by 100
	mflo $v1        # save the result in $v1
	add $v0, $v0, $v1   # add row to $v0
	add $v0, $v0, $t1  # add column to $v0
	move $t3, $v0        # save the concatenated integer in $t3
	div $t0, $t0, 100	#dividing to retain the original value 
	

next:
	# Check if the concatenated integer is already in the array
	beqz $s3, add1_to_array   # branch to add_to_array if arrayCounter == 0
	li $t2, 0               # initialize $t2 to 0
	addi $s5, $s7, 0	#this will be always start at the beginning so it loops through the whole array
loop4:
	bge $t2, $s3, add1_to_array   # branch to add_to_array if $t2 >= arrayCounter
	lw $t4, ($s5)          # load an integer from the array
	beq $t4, $t3, element_exists	#branch if they match 
	addi $t2, $t2, 1       # increment the loop counter
	addi $s5, $s5, 4       # move to the next element of the array
	j loop4

#exit if the element exists 
element_exists:
	li $t3, 0
	j exit

#adding to the element 
add1_to_array:
	sb $t3, ($s4) # array[0] = x *****
	
	addi $s4, $s4, 4 # increment the array pointer by 4
	addi $s3, $s3, 1
	rem $t5, $t0, 2 # t4 = row % 2
	beq $t5, $zero, even	#jump to even if the remainder is zero
	li $t3, 1 # t3 = 1
	j exit
even:
	li $t3, 2 # t3 = 2 
	jr $ra
	
#out of bounds, set $t3 to zero and exit 
out_of_bounds:
	li $t3, 0
	jr $ra
	
# column is even 
column_is_even:
	rem $t5, $t0, 2	#check the remainder of row divided by 2
	beq $t5, $zero, row_isAlso_even		#if the row is even, branch to row is also even 
	j backHere	#if not, go back to where it was called

#$t3 = 0 and exit
row_isAlso_even:
	li $t3, 0
	jr $ra
	
#$t3 = 0 and exit 
column_is_odd:
	li $t3, 0
	jr $ra
	
#check row 
check_row:
	rem $t5, $t0, 2		#check the remainder of row divided by 2
	bne $t5, $zero, column_is_odd	#branch to column is odd if the row is odd
	j singleDigit	#branch back to the next 
	
#exit the call
exit:
	jr $ra
    
