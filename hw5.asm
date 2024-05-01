.text

init_student:
	
	#get bits for ID				#li $t1, 0xFFFFFC0000000000
	lui $t0, 0xFFFF   # Load upper 16 bits of the immediate value into $t0 (for id) (masking)
	ori $t0, $t0, 0xFC00  # OR lower 16 bits of the immediate value into $t0 (for id) (masking) 
	move $t8, $a0    # move the id into t8 
	sll $t8, $t8, 10   #shift it to upper 22 bits for ID
	and $t9, $t0, $t8 # now t9 contains upper 22 bits of ID.
	
	li $t1, 0x3FF      #mask to get first 10 digit of ID 
	move $t7, $a1    # move the credits into t7
	and $t8, $t1, $t7 # now t8 lower 10 bits of t1 contains the credits
	
	#put id and credits together
	or $t6, $t9, $t8 # create the 32 bits that contains both ID and Credits
	sw $t6, 0($a3)  #insert id and credits into the first 23 bits. 
	
	move $t2, $a2  #load the name string 
	sw $t2, 4($a3) #save the name string into the struct 
	
	jr $ra                    # Return 
	
	
print_student:	
	# print ID
	lw $t9, 0($a0)   #load struct into t9 
	move $t4, $a0      #put the address of a0 to t4
	lui $t0, 0xFFFF   # Load upper 16 bits of the immediate value into $t0 (for id) (masking)
	ori $t0, $t0, 0xFC00  # OR lower 16 bits of the immediate value into $t0 (for id) (masking) 
	and $t8, $t0, $t9  #now t8 stores the 32 bits for name 
	srl $t8, $t8, 10             #shift 10 bits down
	li $v0, 1                 # syscall for int 
   	move $a0, $t8             # Load ID into $a0
	syscall 		#print the id out 
	li $v0, 11		#start printing empty space 
	li $t2, ' '		#put empty space in 
	move $a0, $t2             # Load empty space  into $a0
	syscall 
	#print credits	
	lui $t3, 0x0     #masking for 10 bits of credits 
	ori $t3, $t3, 0x3FF 
	and $t7, $t3, $t9   #t7 now has the lower 10 bits as credits 
	li $v0, 1                 # syscall for int 
   	move $a0, $t7             # Load credits into $a0
	syscall 	
	li $v0, 11		#start printing empty space 
	li $t2, ' '		#put empty space in 
	move $a0, $t2             # Load empty space into $a0
	syscall 
	
	# Print name
	lw $t6, 4($t4)  # now t6 stores the address  for name of the struct 
	li $v0, 4                 # System call for string 
	move $a0, $t6             # Load address of name into $a0
	syscall
	jr $ra                    #return 
	
	
init_student_array:
	li $t0, 0                   # i = 0 for loop 
	move $t1, $a0   #t1 now stores the number of students 
	move $t2, $a1      #t2 now has the address of id_list[] 
	move $t3, $a2       #t3 now has the address of the credits[] 
	move $t4, $a3      #t4 now stores the pointer to name.
	lw $t5, 0($sp)      #now t5 has the address of the record [] 
	addi $sp, $sp, -16
	sw $s2, 12($sp)
	sw $ra, 8($sp)             #preseve ra to return to the caller of this function	
	sw $s0, 4($sp)
	sw $s1, 0($sp) 
	
loop_init:
	bge $t0, $t1, loop_init_end # if i >= num of student then exit loop 
	lw $a0, 0($t2)   # put in the id into a0 
	lw $a1, 0($t3)    #put credit into a1 
	addi $t2, $t2,4		#increment t2 to move ot next index
	addi $t3, $t3,4 		#increment t2 to next index 
	li $t8, 0            #x = 0 (used within get name loop)
	move $t6, $t4           #store the address of t4 into t6 
	jal loop_get_name      #go into the loop to get the name 
	move $t6, $t4      	 #store the address of t4 into t6  (again to reset it)
	sub $t6, $t4, $s1
	lw $a2, 0($t4)    #give the address of the char* that we want 
	li $s2, 2           
	lw $a3, 0($t5)		#pass in the address of record[i] into a3 
	addi $t5, $t5, 8          #increment by 8 (size of struct) to move to next index 
	jal init_student  #call init_student 
	addi $t0, $t0, 1 #i++ 
	j loop_init #go back to loop 
	 
loop_get_name: 
	 lb $t9, 0($t6)      #get the char at the address (name[x])
	 beqz $t9, loop_get_name_end  # end loop if we encounter \0
	 addi $t6, $t6,1 #x++ 
	 j loop_get_name  #loop again 
	 
	 

loop_get_name_end: 
	addi $s1, $t8, 1
	add $t4, $t4, $s1  #now t4 has the address of the string after null terminator 
	jr $ra   #return 
	
	
loop_init_end: 
	lw $s2, 12($sp)
	lw $ra, 8($sp) #retrieve ra 
	lw $s0, 4($sp)	#retrieve s0
	lw $s1, 0($sp)  #retrieve s1 
	addi $sp, $sp, 12    #restore sp 
	jr $ra      #return 
	
	
insert:
	jr $ra
	
search:
	jr $ra

delete:
	jr $ra