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
	addi $sp, $sp, -4
	sw $v0, 0($sp)
	lw $t9, 0($a0)   #load struct into t9 
	move $t4, $a0      #put the address of a0 to t4
	lui $t0, 0xFFFF   # Load upper 16 bits of the immediate value into $t0 (for id) (masking)
	ori $t0, $t0, 0xFC00  # OR lower 16 bits of the immediate value into $t0 (for id) (masking) 
	and $t8, $t0, $t9  #now t8 stores the 32 bits for id and credits 
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
	lw $v0, 0($sp)
	addi $sp, $sp, 4
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
	move $a2, $t6    #give the address of the char* that we want 
	li $s2, 2           
	move $a3, $t5		#pass in the address of record[i] into a3 
	addi $t5, $t5, 8          #increment by 8 (size of struct) to move to next index 
	addi $sp, $sp, -40        
    	sw $t0, 0($sp)            
    	sw $t1, 4($sp)          
    	sw $t2, 8($sp)           
    	sw $t3, 12($sp)         
    	sw $t4, 16($sp)           
    	sw $t5, 20($sp)          
    	sw $t6, 24($sp)           
    	sw $t7, 28($sp)           
    	sw $t8, 32($sp)         
    	sw $t9, 36($sp)          
	jal init_student  #call init_student 
	lw $t9, 36($sp)          
    	lw $t8, 32($sp)           
    	lw $t7, 28($sp)           
    	lw $t6, 24($sp)          
    	lw $t5, 20($sp)           
    	lw $t4, 16($sp)          
    	lw $t3, 12($sp)           
    	lw $t2, 8($sp)           
    	lw $t1, 4($sp)            
    	lw $t0, 0($sp)            
    	addi $sp, $sp, 40         # Deallocate space on the stack
	addi $t0, $t0, 1 #i++ 
	j loop_init #go back to loop 
	 
loop_get_name: 
	 lb $t9, 0($t6)      #get the char at the address (name[x])
	 beqz $t9, loop_get_name_end  # end loop if we encounter \0
	 addi $t6, $t6,1 #x++ 
	 addi $t8, $t8, 1 #t8 is the index as well. when it goes to loop end it is at the index of \0
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
	# get the ID 
	lw $t9, 0($a0)   #load struct into t9 
	lui $t0, 0xFFFF   # Load upper 16 bits of the immediate value into $t0 (for id) (masking)
	ori $t0, $t0, 0xFC00  # OR lower 16 bits of the immediate value into $t0 (for id) (masking) 
	and $t8, $t0, $t9  #now t8 stores the 32 bits for id and credits 
	srl $t8, $t8, 10             #shift 10 bits down to get the id only  now t8 has the id only 
   	
   	#now do the hash index
   	div $t8, $a2   #do the division 
   	mfhi $t7 	#get the MOD result into t7 (the index) 
   	
   	#now get the actual address of hash index 
   	li $t6, 4    #multiplier to get the actual address of the index 
   	addi $t0, $a2, -1     #get the index of the last index of array
   	mult $t0, $t6    #multiply index by 4 
   	mflo $t0      #now t0 has the offset of address of the last elemnent of the array   
   	add $t0, $t0, $a1 #now t0 actually has the actual address of the last element 
   	mult $t6, $t7 #get the offset of actual address of index. (index * 4) 
   	mflo $t7       #now t7 contains offset of the actual address index, instead of just the hash index 
   	add $t8, $t7, $a1 #  now t8 has the actual address of the index address of first element + the offset to get table[index]
   	
   
   	#might have to move above 2 lines into loop 
insert_loop:
	lw $t6, 0($t8) #now t6 has the contents at table[index] 
	beqz $t6, insert_ok   # if it's empty then insert 
	li $t3, -1         #load -1 into $t3 
	beq $t6, $t3 , insert_ok   #tombstone, insert as well
	move $t5, $a1      #put the initial address back to $t5 (to use in loop around) 
	beq $t8,$t0, loop_around #if we couldn't insert and we reach the end of array (gotta consider two conditions:first time looping and second time) 
	addi $t8,$t8,4   #move to next address (if we go into loop_around, it will change it to the beginning address) 
	j insert_loop        # loop again
	
#note i already saved ra in the beginning 
loop_around:
	lw $t6, 0($t5) #now t6 has the contents at table[index] 
	beqz $t6, insert_ok_2   # if it's empty then insert 
	li $t3, -1         #load -1 into $t3 
	beq $t6, $t3 , insert_ok_2   #tombstone, insert as well
	beq $t5,$t0, insert_failed #we already looped but still couldn't find spot. insert failed. 
	addi $t5,$t5,4   #move to next address (if we go into loop_around, it will change it to the beginning address) 
	j loop_around        # loop again
	
	
insert_ok:#uses t8 (the actual address to be inserted)
	sw $a0, 0($t8) #save the struct into the table 
	#calculate the index 
	sub $t1, $t8, $a1   #get the index (insert adderess - src address of table) 
	li $t8, 4
	div $t1, $t8       #dividing difference of address by 4 to get index 
	mflo $t7    #now t7 has the table index of inserted 
	move $v0, $t7      #move t1 (the index) into v0 to return 
	jr $ra 
	
insert_ok_2: #uses t5 (the actual address to be inserted)
	sw $a0, 0($t5) #save the struct into the table 
	#calculate the index 
	sub $t1, $t5, $a1   #get the index (insert adderess - src address of table) 
	li $t8, 4
	div $t1, $t8       #dividing difference of address by 4 to get index 
	mflo $t7    #now t7 has the table index of inserted 
	move $v0, $t7      #move t1 (the index) into v0 to return 
	jr $ra 
	
insert_failed:
	li $t2, -1     #load -1 into t2 for failed insert 
	move $v0, $t2     #move t2 which is -1 into v0 for return 
	jr $ra     



search:
	#get masking 
	lui $t0, 0xFFFF   # Load upper 16 bits of the immediate value into $t0 (for id) (masking)
	ori $t0, $t0, 0xFC00  # OR lower 16 bits of the immediate value into $t0 (for id) (masking) 
	li $t6, 4    #multiplier to get the actual address of the index 
   	addi $t7, $a2, -1     #get the index of the last index of array
   	mult $t7, $t6    #multiply index by 4 
   	mflo $t7      #now t7 has the offset of address of the last elemnent of the array   
   	add $t7, $t7, $a1 #now t7 actually has the actual address of the last element of the table
   	move $t1, $a1      #move the table address into t1 
	#now start extracting the record 
loop_search: 
	lw $t2, 0($t1) #now t2 has the address of the contents at table[index] 
	li $t3, -1         #load -1 into $t3 (tombstone)
	beqz $t2, continue_loop_search #if it's empty then skip 
	beq $t2,$t3, continue_loop_search  #if its tombstone also skip 
	#reach here means it has a student record. t2 has the address of record 
	lw $t4, 0($t2)    #get the content from the address of record 
	and $t5,$t4,$t0    
	srl $t5, $t5, 10  #shift 10 bits down to get the id only  now t5 has the id only 
	beq $t5,$a0, found_it  #check if the id is the one wanted 
	j continue_loop_search 
	
continue_loop_search: 
	beq $t7,$t1, search_failed #if you reach the end of table and didnt find it. failed. 
	add $t1,$t1,$t6     #move to next address (address +4) 
	j loop_search  #go back to loop_search to loop again 

search_failed:
	li $v0,0 #0 for  not found 
	li $v1,-1 #-1 for not found 
	jr $ra #return 

found_it:
	move $v0, $t2  #give the address of record found
	#calculate the index 
	sub $t1, $t1, $a1   #get the address difference (insert adderess - src address of table) 
	li $t6, 4
	div $t1, $t6       #dividing difference of address by 4 to get index 
	mflo $t1    #now t1 has the table index of found
	move $v1, $t1		#move the found index into v1 for return 
	jr $ra #return 
delete:
	jr $ra