.text

init_student:
	# Load arguments
	#$a0 # Load ID
	#$a1  # Load Credits
	#$a2   # Load address of name
	#$a3   # Load record struct 
	
	#get bits for ID				#li $t1, 0xFFFFFC0000000000
	lui $t0, 0xFFFF   # Load upper 16 bits of the immediate value into $t0 (for id) (masking)
	ori $t0, $t0, 0xFC00  # OR lower 16 bits of the immediate value into $t0 (for id) (masking) 
	lw $t8, 0($a0)    # load the id into t8 
	sll $t8, $t8, 10   #shift it to upper 22 bits for ID
	and $t9, $t0, $t8 # now t9 contains upper 22 bits of ID.
	
	li $t1, 0x3FF      #mask to get first 10 digit of ID 
	lw $t7, 0($a0)    # load the credits into t7
	and $t8, $t1, $t7 # now t8 lower 10 bits of t1 contains the credits
	
	#put id and credits together
	and $t6, $t9, $t8 # create the 32 bits that contains both ID and Credits
	sw $t6, 0($a3)  #insert id and credits into the first 23 bits. 
	
	lw $t2, 0($a2)  #load the name string 
	sw $t2, 4($a3) #save the name string into the struct 
	
	jr $ra                    # Return 
	
	
print_student:	
	# print ID
	lw $t9, 0($a0)   #load the address of struct into t9 
	lui $t0, 0xFFFF   # Load upper 16 bits of the immediate value into $t0 (for id) (masking)
	ori $t0, $t0, 0xFC00  # OR lower 16 bits of the immediate value into $t0 (for id) (masking) 
	and $t8, $t0, $t9  #now t8 stores the 32 bits for name 
	srl $t8, $t8, 10             #shift 10 bits down
	li $v0, 1                 # syscall for int 
   	move $a0, $t8             # Load ID into $a0
    	syscall 	
    	#print credits	
	lui $t3, 0x0     #masking for 10 bits of credits 
	ori $t3, $t3, 0x3FF 
	and $t7, $t3, $t9   #t7 now has the lower 10 bits as credits 
	li $v0, 1                 # syscall for int 
   	move $a0, $t7             # Load credits into $a0
    	syscall 		
    	# Print name
    	lw $t6, 4($t9)  # now t6 stores the address for name of the struct 
    	li $v0, 4                 # System call for string 
    	move $a0, $t6             # Load address of name into $a0
    	syscall
	jr $ra                    #return 
	
	
init_student_array:
	jr $ra
	
insert:
	jr $ra
	
search:
	jr $ra

delete:
	jr $ra