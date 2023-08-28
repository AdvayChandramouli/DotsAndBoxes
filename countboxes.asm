#Advay Chandramouli
#CS2340.004 - Group Project
#Implementing function to count boxes

.eqv COLMAX 17
.eqv ROWMAX 13

.data	
	#rowMax: .word 13
	#colMax: .word 17
	player: .word 0
	computer: .word 0

	verticalLine: .byte '|'
	horizontalLine: .byte '-' 
	blankSpace: .byte ' '
	
	playerScore: .asciiz "\nPlayer Score: "
	compScore: .asciiz "\nComputer Score: "
.text
	#t0 = x, t1 = y ==> move to a0 and a1, 
	#t6 - row max
	#t7 - col max	
	#first divide both x and y by 2. check remainders, for conditions....
        
	#arguments - x (a0), y (a1)
	#read globals - rowmax & colmax
	#read boolean turn
	#read globals - player & computer
	
	
	countBox:
		addi $sp, $sp, -4
		sw $ra, ($sp)
		
		# determine if x is even or odd
		li $t3, 1
		and $t3, $t3, $a0
		
		#la $t6, rowMax
		#lw $t6, 0($t6)
		#la $t7, colMax
		#lw $t7, 0($t7)
		
		li $t6, ROWMAX
		li $t7, COLMAX
		
		move $t0, $a0
		move $t1, $a1
		move $t2, $a2
		
		beq $t3, $zero, vertical
		
	horizontal:
		#if y > 0 (not first row), branch to horizontalNZ (checks box above)
		bgtz $a1, horizontalNZ
		#if y == first row, check box below
		blt $a1, $t6, horizontalFR
		
	#horizontal at y != 0
	horizontalNZ:
		#check empty char at middle cell (x, y-1)
		addi $a0, $t0, 0
		addi $a1, $t1, -1
		la $a2, blankSpace
		lb $a2, 0($a2)
		jal checkChar
		beq $v0, 0, horizontalFR
		
		#STEP 1: check vertical from (x-1,y-1) ==> subtract 1 from t0, t1 (x-1, y-1)
		addi $a0, $t0, -1
		addi $a1, $t1, -1
		la $a2, verticalLine
		lb $a2, 0($a2)
		jal checkChar
		beq $v0, 0, horizontalFR
		
		#STEP 2: check vertical from (x+1,y-1) == '|'
		addi $a0, $t0, 1
		addi $a1, $t1, -1
		la $a2, verticalLine
		lb $a2, 0($a2)
		jal checkChar
		beq $v0, 0, horizontalFR
		
		#STEP 3: check horizontal (x, y-2)
		addi $a0, $t0, 0
		addi $a1, $t1, -2
		la $a2, horizontalLine
		lb $a2, 0($a2)
		jal checkChar
		beq $v0, 0, horizontalFR
		
		addi $a0, $t0, 0
		addi $a1, $t1, -1
		move $a2, $t2 #has turn value
		jal fillChar
	
	#horizontal at y = 0
	horizontalFR:
		#check middle box (x,y+1) IS EMPTY
		addi $a0, $t0, 0
		addi $a1, $t1, 1
		la $a2, blankSpace
		lb $a2, 0($a2)
		jal checkChar
		beq $v0, 0, retFromCount
		
		#check vertical  (x-1,y+1)
		addi $a0, $t0, -1
		addi $a1, $t1, 1
		la $a2, verticalLine
		lb $a2, 0($a2)
		jal checkChar
		beq $v0, 0, retFromCount
		
		#check vertical  (x+1,y+1)
		addi $a0, $t0, 1
		addi $a1, $t1, 1
		la $a2, verticalLine
		lb $a2, 0($a2)
		jal checkChar
		beq $v0, 0, retFromCount
		
		#check horizontal (x,y+2) = '-'
		addi $a0, $t0, 0
		addi $a1, $t1, 2
		la $a2, horizontalLine
		lb $a2, 0($a2)
		jal checkChar
		beq $v0, 0, retFromCount
		
		addi $a0, $t0, 0
		addi $a1, $t1, 1
		move $a2, $t2 #has turn value
		jal fillChar
	
	vertical:
		bgtz $t0, verticalNZ
		blt $t0, $t7, verticalFC
		
	#vertical at x != 0
	verticalNZ:
		#check middle box (x-1,y) IS EMPTY
		addi $a0, $t0, -1
		addi $a1, $t1, 0
		la $a2, blankSpace
		lb $a2, 0($a2)
		jal checkChar
		beq $v0, 0, verticalFC
		
		#check horizontal from (x-1,y-1)
		addi $a0, $t0, -1
		addi $a1, $t1, -1
		la $a2, horizontalLine
		lb $a2, 0($a2)
		jal checkChar
		beq $v0, 0, verticalFC
		
		#check horizontal from (x-1,y+1)
		addi $a0, $t0, -1
		addi $a1, $t1, 1
		la $a2, horizontalLine
		lb $a2, 0($a2)
		jal checkChar
		beq $v0, 0, verticalFC
		
		#check vertical from (x-2,y)
		addi $a0, $t0, -2
		addi $a1, $t1, 0
		la $a2, verticalLine
		lb $a2, 0($a2)
		jal checkChar
		beq $v0, 0, verticalFC
		
		addi $a0, $t0, -1
		addi $a1, $t1, 0
		move $a2, $t2 #has turn value
		jal fillChar
		
	#vertical at x = 0
	verticalFC:
		#check (x+1,y) IS EMPTY
		addi $a0, $t0, 1
		addi $a1, $t1, 0
		la $a2, blankSpace
		lb $a2, 0($a2)
		jal checkChar
		beq $v0, 0, retFromCount
		
		#check horizontal (x+1,y+1)
		addi $a0, $t0, 1
		addi $a1, $t1, 1
		la $a2, horizontalLine
		lb $a2, 0($a2)
		jal checkChar
		beq $v0, 0, retFromCount
		
		#check horizontal (x+1, y-1)
		addi $a0, $t0, 1
		addi $a1, $t1, -1
		la $a2, horizontalLine
		lb $a2, 0($a2)
		jal checkChar
		beq $v0, 0, retFromCount
		
		#check vertical (x+2, y)
		addi $a0, $t0, -2
		addi $a1, $t1, 0
		la $a2, verticalLine
		lb $a2, 0($a2)
		jal checkChar
		beq $v0, 0, retFromCount
		
		addi $a0, $t0, 1
		addi $a1, $t1, 0
		move $a2, $t2 #has turn value
		jal fillChar
		
	#return from countbox
	retFromCount:
		lw $ra, ($sp)
		addi $sp, $sp, 4
		jr $ra

	#checks for character (x, y, c) where x and y are coordinates, and c is the character to check for. Returns 0 or 1. 	
	checkChar:
	
		#la $a3, colMax
		#lw $a3, 0($a3)
		
		li $a3, COLMAX
		
		#a1 = #of rows * colMax
		mul $a1, $a1, $a3
		#OFFSET ==> a1 = (r*maxcols) + c
		add $a1, $a1, $a0

		#load char from memory
		#la $a3, ($s0)
		add $a3, $s0, $a1
		lb $a1, 0($a3)
		seq $v0, $a1, $a2
		
		jr $ra
		
	#fill middle box if a box is completed. increment respective user's score if box is found.
	#t6 has turn value - if 0, player if 1, computer
	fillChar:
		beqz $a2, fillPlayer
		
		li $v0, 0x43 #set to C
		la $v1, computer
		lw $a3, 0($v1)
		addi $a3, $a3, 1
		sw $a3, 0($v1)
		
		j writeChar
		
	fillPlayer:
		li $v0, 0x50 #set to P
		#increment player count
		la $v1, player
		lw $a3, 0($v1)
		addi $a3, $a3, 1
		sw $a3, 0($v1)
	
	writeChar:
		#calculate offset
		#la $a3, colMax
		#lw $a3, 0($a3)
		li $a3, COLMAX
		mul $a1, $a1, $a3
		#OFFSET ==> a1 = (r*maxcols) + c
		add $a1, $a1, $a0
		
		#load base address, add offset
		#la $a3, ($s0)
		add $a3, $s0, $a1
		
		#store character in memory index
		sb $v0, 0($a3)
		
		jr $ra
		
	printScore:
		li $v0, 4
		la $a0, playerScore
		syscall
		
		li $v0, 1
		la $a0, player
		lw $a0, 0($a0)
		syscall
		
		move $a2, $a0
		
		li $v0, 4
		la $a0, compScore
		syscall
		
		li $v0, 1
		la $a0, computer
		lw $a0, 0($a0)
		syscall
		
		add $a2, $a2, $a0 #current num of squares
		
		li $a0, ROWMAX
		li $a1, COLMAX
		
		srl $a0, $a0, 1
		srl $a1, $a1, 1
		
		mul $a0, $a0, $a1 #total number of squares
		
		seq $v0, $a0, $a2
		jr $ra
		
		
		
		
		
