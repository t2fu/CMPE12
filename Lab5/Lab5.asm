##########################################################################
# Created by: Fu, Tiancheng
# CruzID: tfu6
# 15th March 2019
#
# Assignment: Lab 5: Subroutines
# CMPE 012, Computer Systems and Assembly Language
# UC Santa Cruz, Winter 2019
#
# Description: The Lab5.asm file only contian subroutines that are suppose to be run on Lab5MainThe input of the program
# should be strings. There are seven main subroutines in this program in total, they are "give_prompt", "cipher", "compute_checksum",
# "encrypt", " decrypt", "check_ascii", "print_strings".  The subroutines access the different array in the program and change the
# values in their addresses. The program first will output message to the user and allow the user to inputs and save the
# input to different arrays. Then the "cipher" subroutine will decides the encrypt and decrypt procress. At last, the "print_strings"
# subroutine will output the resulting encrypt/decrypt string arrays to the user.

# Notes: This program is intended to be run from the MARS IDE. The Lab5Main.asm file must be included in the same folder as
# the Lab5.asm file. The Lab5.asm file only contian subroutines that are suppose to be run on Lab5MainThe input of the program should be strings.
# Wrong inputs may result in runtime errors.
##########################################################################

.data                 # declare all of the string arrays and ouputs to the user
error: .asciiz "Invalid input: Please input E, D, or X."
newLine: .asciiz "\n"
input: .space 101      # Store the user input (E)Encrypted or (D)Decrypted choice
key: .space 101        # Store the user input key string value
edcrypt: .space 101    # Store the user input Encrypted or Decrypted string value
result: .space 101     # Store the final resulting Encrypted or Decrypted value
encrypted: .asciiz "<Encrypted> "
decrypted: .asciiz "<Decrypted> "
.text
#--------------------------------------------------------------------
# give_prompt
#
# This function should print the string in $a0 to the user, store the user’s input in
# an array, and return the address of that array in $v0. Use the prompt number in $a1
# to determine which array to store the user’s input in. Include error checking for
# the first prompt to see if user input E, D, or X if not print error message and ask
# again.
#
# arguments: $a0 - address of string prompt to be printed to user
# $a1 - prompt number (0, 1, or 2)
#
# note: prompt 0: Do you want to (E)ncrypt, (D)ecrypt, or e(X)it?
# prompt 1: What is the key?
# prompt 2: What is the string?
#
# return: $v0 - address of the corresponding user input data
#--------------------------------------------------------------------
give_prompt:
  
  beq  $a1, 0, g_prompt0 # Determine which prompt by the value of $a1
  beq  $a1, 1, g_prompt1
  beq  $a1, 2, g_prompt2
  
  jp1:            # branch back if user entered a invalid message
    la $a0, newLine
    li $v0, 4
    syscall
    la $a0, error # display error message
    li $v0, 4
    syscall   
    la $a0, newLine
    li $v0, 4
    syscall
  g_prompt0:      # display the first prompt message
    la $a0, prompt0
    li $v0, 4
    syscall
    
    la $a0, input
    la $a1, 2
    li $v0, 8     # Read the user's respond for the first prompt and store it to the input array
    syscall
    
    la $v0, input # return the address of the input array to the main program
    
    lb $t0, ($v0)
    bne $t0, 0x44, jp2
    b jp4
                  # checking the user input value for the first prompt and branch to jp1 if the user input value is invalid
   jp2:
    bne $t0, 0x45, jp3
    b jp4
   jp3:
    bne $t0, 0x58, jp1
   jp4:
   
   jr $ra         # jump back to Lab5Main.asm
    
   g_prompt1:     # Output the second prompt and store the user input key into the key string array
   la $a0, newLine
   li $v0, 4
   syscall
   
   la $a0, prompt1
   li $v0, 4
   syscall
   
    la $t0, key 
    
    la $a0, ($t0)
    li $a1, 256
    li $v0, 8
    syscall
    
    move $v0,$a0  # return the address of the key array to the main program

   jr $ra         # jump back to Lab5Main.asm
   
   g_prompt2:     # Output the third prompt and store the user input Encrypted or Decrypted string into the edcrypt string array

   la $a0, prompt2
   li $v0, 4
   syscall   
 
    la $t0, edcrypt
    
    la $a0, ($t0)
    li $a1, 256
    li $v0, 8
    syscall
    
    move $v0,$a0 # return the address of the edcrypt array to the main program
   
   jr $ra        # jump back to Lab5Main.asm
#--------------------------------------------------------------------
# cipher
#
# Calls compute_checksum and encrypt or decrypt depending on if the user input E or
# D. The numerical key from compute_checksum is passed into either encrypt or decrypt
#
# note: this should call compute_checksum and then either encrypt or decrypt
#
# arguments: $a0 - address of E or D character
# $a1 - address of key string
# $a2 - address of user input string
#
# return: $v0 - address of resulting encrypted/decrypted string
#--------------------------------------------------------------------
cipher:
    subi $sp, $sp, 4    # push the original value of $a0 into the stack
    sw $a0, ($sp)
    move $a0, $a1
    b compute_checksum
    
    ed:
    lw $a0, ($sp)       # pop the original value of $a0 into the stack and store it back to $a0
    addi $sp, $sp, 4
    
    move $t2, $a1
    move $a1, $v0       # checksum result stored into $a1
    
    lb $t8, ($a0)
    move $t5, $a2       # index of the edcrypt array; uses to loop through the array
    la $t9, result
    beq $t8, 0x45, enc  # is user entered "E" then encrypt
    beq $t8, 0x44, dec  # is user entered "D" then decrypt
    
    	enc:            # loop through all the values stored in the edcrypt and encrypt all its values
    	
    	lb $a0, ($t5)
    	b encrypt
    	
    	exit2:
   	 sb $v0, ($t9)
        addi $t5, $t5, 1
        addi $t9, $t9, 1
        lb $t1, ($t5)
        bne $t1, 0x0a, enc # encrypt the currect edcrypt value and store the result to the result array address
        b exit4
        
    	dec:
    	
    	lb $a0, ($t5)
    	b decrypt   	
    	
    	exit3:          # loop through all the values stored in the edcrypt and decrypt all its values
    	sb $v0, ($t9) 
    	 addi $t5, $t5, 1
    	 addi $t9, $t9, 1
    	 lb $t1, ($t5)
        bne $t1, 0x0a, dec # decrypt the currect edcrypt value and store the result to the result array address
        b exit4
    	
    	exit4:		  # output the result array address to the main
        move $a1, $t2
        la $v0, result
        jr $ra
#--------------------------------------------------------------------
# compute_checksum
#
# Computes the checksum by xor’ing each character in the key together. Then,
# use mod 26 in order to return a value between 0 and 25.
#
# arguments: $a0 - address of key string
#
# return: $v0 - numerical checksum result (value should be between 0
#--------------------------------------------------------------------
compute_checksum:
  addi $t0, $zero, 0 # sum
  move $t5, $a0 # index
  #addi $t5, $t5, 4
  lb $t1, ($t5)
  loop1:
  
  xor $t0, $t1, $t0
  b exit1
  
  exit1:
  addi $t5, $t5, 1
  lb $t1, ($t5)
  bne $t1, 0x0a, loop1
  
  li $t1, 26
  div $t0, $t1
  mfhi $t6
  
  la $v0, ($t6)
 
  #la $a0, ($t6)
  #li $v0, 1
  # syscall
  b ed
#--------------------------------------------------------------------
# encrypt
#
# Uses a Caesar cipher to encrypt a character using the key returned from
# compute_checksum. This function should call check_ascii.
#
# arguments: $a0 - character to encrypt
# $a1 - checksum result
#
# return: $v0 - encrypted character
#--------------------------------------------------------------------
encrypt:
	
	b check_ascii
	
	checkee:             # check what type of the character is the currect character
	beq $v0, -1, symbole
        beq $v0, 0, upper
        beq $v0, 1, lower
        
       symbole:
        move  $v0, $a0      # no operation to the symbol value
        b noAction
        
       upper:
	li $t0, 90           # the maximum value in the uppercase character ascii code
	move $t7, $a0
	sub $a0, $t0, $a0    # a0 is the remainder of (maximum value - current character)
	sub $a0, $a1, $a0
	beq $a0, 1, no_remain
	beqz $a0, no_remain
	bnez $a0, remain
	b noAction
	
	remain:              # add the remainder to the minimum value in the uppercase character ascii code if there is remainder
	li $t0, 64         
        add $a0, $t0, $a0
	move $v0, $a0
	b noAction
	
	no_remain:           # add the remainder to the checksum result in the uppercase character ascii code if there is no remainder
	move $a0, $t7
	sub $a0, $a0, $a1
	move $v0, $a0
	b noAction
	
	lower:
	li $t0, 122	      # the maximum value in the lowercase character ascii code
	move $t7, $a0
	sub $a0, $t0, $a0
	sub $a0, $a1, $a0
	beq $a0, 1, no_remainl
	beqz $a0, no_remainl
	bnez $a0, remainl
	b noAction

	                     # the encrypt function for lowercase ascii character has the similar logic compared to the uppercase ascii character
	remainl:
	li $t0, 96           # minimum value for the lowercase character ascii code
        add $a0, $t0, $a0
	move $v0, $a0
	b noAction
		
	no_remainl:
	move $a0, $t7
	sub $a0, $a0, $a1
	move $v0, $a0
	b noAction 
	
        noAction:
        b exit2              # loop to the next ascii character to edcrypt

#--------------------------------------------------------------------
# decrypt
#
# Uses a Caesar cipher to decrypt a character using the key returned from
# compute_checksum. This function should call check_ascii.
#
# arguments: $a0 - character to decrypt
# $a1 - checksum result
#
# return: $v0 - decrypted character
#--------------------------------------------------------------------
decrypt:
	
	b check_ascii
	
	checked:		# check what type of the character is the currect character
	
	beq $v0, -1, symbold
        beq $v0, 0, upperd
        beq $v0, 1, lowerd
       
       symbold:			# no operation to the symbol value
        move $v0, $a0
        b noActiond
       
       upperd:
	li $t0, 65 		 # the minimum value in the uppercase character ascii code
	sub $a0, $a0, $t0	 # a0 is the remainder of (current character - minimum uppercase character ascii value)
	sub $a0, $a1, $a0
	beq $a0, -1, no_remaind
	beq $a0, -2, no_remaind
	beq $a0, -3, no_remaind
	beq $a0, -4, no_remaind
	beq $a0, -5, no_remaind
	beqz $a0, no_remaind
	bnez $a0, remaind
	b noActiond
	
	remaind:		# subtract the remainder from the maximum value in the uppercase character ascii code if there is remainder
	li $t0, 91 		# almost the maximum value in the uppercase character ascii code
        sub $a0, $t0, $a0
	move $v0, $a0
	b noActiond
	
	no_remaind:		# subtract the remainder from the minimum value of the uppercase character ascii code if there is no remainder
	li $t0, 65             # the minimum value in the uppercase character ascii code
	sub $a0, $t0, $a0
	move $v0, $a0
	b noActiond
				# the decrypt function for lowercase ascii character has the similar logic compared to the uppercase ascii character
	lowerd:
	li $t0, 97 		# the minimum value in the lowercase character ascii code
	sub $a0, $a0, $t0
	sub $a0, $a1, $a0
	beq $a0, -1, no_remaindl
	beq $a0, -2, no_remaindl
	beq $a0, -3, no_remaindl
	beq $a0, -4, no_remaindl
	beq $a0, -5, no_remaindl
	beqz $a0, no_remaindl
	bnez $a0, remaindl
	b noActiond
	
	remaindl:
	li $t0, 123 		# almost the maximum value in the lowercase character ascii code
        sub $a0, $t0, $a0
	move $v0, $a0
	b noActiond
		
	no_remaindl:
	li $t0, 97 #min
	sub $a0, $t0, $a0
	move $v0, $a0
	b noActiond	
	
        noActiond:
        b exit3			# loop to the next ascii character to decrypt

#--------------------------------------------------------------------
# check_ascii
#
# This checks if a character is an uppercase letter, lowercase letter, or
# not a letter at all. Returns 0, 1, or -1 for each case, respectively.
#
# arguments: $a0 - character to check
#
# return: $v0 - 0 if uppercase, 1 if lowercase, -1 if not letter
#--------------------------------------------------------------------
check_ascii:
	bgt $a0, 0x40, check0	    #check the ascii value range of lowercase characters
	b notletter
	
	check0:
	  bgt $a0 ,0x5a, check1    #check the ascii value range of lowercase characters
	  b uppercase
	 
	check1:
	  bgt $a0, 0x60, check2    #check the ascii value range of uppercase characters
	  b notletter
	  
	 check2:
	  bgt $a0, 0x7a, notletter #check the ascii value range of uppercase characters
	  b lowercase
	  
	 uppercase:		
	  li $v0, 0		# if the current character is a uppercase character the return $v0 = 0
          beq $t8, 0x45, checkee
          beq $t8, 0x44, checked
	 
	 lowercase:		# if the current character is a lowercase character the return $v0 = 1
	  li $v0, 1
          beq $t8, 0x45, checkee
          beq $t8, 0x44, checked
	  
	 notletter:		# if the current character is not a lowercase or a uppercase character then it is not a letter and returns $v0 = -1
	  li $v0, -1	  
          beq $t8, 0x45, checkee
          beq $t8, 0x44, checked
#--------------------------------------------------------------------
# print_strings
#
# Determines if user input is the encrypted or decrypted string in order
# to print accordingly. Prints encrypted string and decrypted string. See
# example output for more detail.
#
# arguments: $a0 - address of user input string to be printed
# $a1 - address of resulting encrypted/decrypted string to be printed
# $a2 - address of E or D character
#
# return: prints to console
#--------------------------------------------------------------------
print_strings:
    lb $t8, ($a2)
    move $t9, $a0
    beq $t8, 0x45, encypt
    beq $t8, 0x44, decypt
    
    encypt:
       move $t1, $a1	 # address of the decypted string array
       move $t2, $a0	 # address of the encypted string array
    	b output1
    decypt:
       move $t1, $a0	 # address of the encypted string array
       move $t2, $a1	 # address of the decypted string array
        b output1
        
    output1:		 # loop through the encypted string array and print out all string character value in the array
      la $a0, encrypted
      li $v0, 4
      syscall
      
       li $v0, 4
       la $a0, ($t1)
       syscall
       
      la $a0, newLine
      li $v0, 4
      syscall
     
     output2:		 # loop through the decrypted string array and print out all string character value in the array
      li $v0, 4
      la $a0, decrypted
      syscall

       li $v0, 4
       la $a0, ($t2)
       syscall
                     
   jr $ra         	# jump back to Lab5Main.asm
