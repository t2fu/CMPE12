##########################################################################
# Created by: Fu, Tiancheng
# CruzID: tfu6
# 15th March 2019
#
# Assignment: Lab 5: Subroutines
# CMPE 012, Computer Systems and Assembly Language
# UC Santa Cruz, Winter 2019
#
# Description: This program read two 8-bit 2'S Complement number and will add them to a sum and output it. The program will convert the two input arguments
# into 32-bit sign extend 2's Complement number and store them in register $s1 and $s2. Then the program will add the value stores in the register $s1
# and $s2 into $s0 and output the sum in base 4 with a magnitude and a negative sign if the sum is negative.
#
# Notes: This program is intended to be run from the MARS IDE. These numbers may be entered as hex
# (using the “0x” prefix) or binary (using the “0b” prefix). The range of these
# inputs are: [0x80, 0x7F] in hex or [0b10000000, 0b01111111] in binary. Note
# that this range is [-128, 127] in decimal. Input arguments out of the range may
# result in runtime errors.
##########################################################################
.data
error: .asciiz "Invalid input: Please input E, D, or X."
newLine: .asciiz "\n"
input: .space 101
key: .space 101
edcrypt: .space 101
result: .space 101
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
  
  beq  $a1, 0, g_prompt0
  beq  $a1, 1, g_prompt1
  beq  $a1, 2, g_prompt2
  
  jp1:
    la $a0, newLine
    li $v0, 4
    syscall
    la $a0, error
    li $v0, 4
    syscall   
    la $a0, newLine
    li $v0, 4
    syscall
  g_prompt0:
    la $a0, prompt0
    li $v0, 4
    syscall
    
    la $a0, input
    la $a1, 2
    li $v0, 8        # Read the user's respond for the first message
    syscall
    #li, $a1, 2
    la $v0, input
    
    lb $t0, ($v0)
    bne $t0, 0x44, jp2
    b jp4
   jp2:
     bne $t0, 0x45, jp3
    b jp4
   jp3:
    bne $t0, 0x58, jp1
   jp4:
   
   jr $ra
    
   g_prompt1:
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
    
    move $v0,$a0

   jr $ra
   
   g_prompt2:

   la $a0, prompt2
   li $v0, 4
   syscall   
 
    la $t0, edcrypt
    
    la $a0, ($t0)
    li $a1, 256
    li $v0, 8
    syscall
    
    move $v0,$a0   
   
   jr $ra
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
    subi $sp, $sp, 4
    sw $a0, ($sp)
    move $a0, $a1
    b compute_checksum
    
    ed:
    lw $a0, ($sp)
    addi $sp, $sp, 4
    
    move $s5, $a1
    move $a1, $v0
    
    lb $t8, ($a0)
    move $t5, $a2 # index
    la $t9, result
    beq $t8, 0x45, enc
    beq $t8, 0x44, dec
    
    	enc:
    	
    	lb $a0, ($t5)
    	b encrypt
    	
    	exit2:
   	sb $v0, ($t9)
        addi $t5, $t5, 1
        addi $t9, $t9, 1
        lb $t1, ($t5)
        bne $t1, 0x0a, enc
        b exit4
        
    	dec:
    	
    	lb $a0, ($t5)
    	b decrypt   	
    	
    	exit3:
    	sb $v0, ($t9) 
    	 addi $t5, $t5, 1
    	 addi $t9, $t9, 1
    	 lb $t1, ($t5)
        bne $t1, 0x0a, dec
        b exit4
    	
    	exit4:
        move $a1, $s5
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
	
	checkee:
	beq $v0, -1, symbole
        beq $v0, 0, upper
        beq $v0, 1, lower
        
       symbole:
        move  $v0, $a0
        b noAction
        
       upper:
       	beq $a0, 0x65, outofb1
	beq $a0, 0x66, outofb2
	addi $a0, $a0, -2
	move $v0, $a0
	b noAction
	
	outofb1:
	li $a0, 0x59
	move $v0, $a0
	b noAction
	
	outofb2:
	li $a0, 0x5a
	move $v0, $a0
	b noAction
	
	lower:
	beq $a0, 0x61, outofb3
	beq $a0, 0x62, outofb4
        addi $a0, $a0, -2
	move $v0, $a0
	b noAction
	
	
	outofb3:
	li $a0, 0x79
	move $v0, $a0
	b noAction
		
	outofb4:
	li $a0, 0x7a
	move $v0, $a0
	b noAction	
	
        noAction:
        b exit2

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
	
	checked:
	
	beq $v0, -1, symbold
        beq $v0, 0, upperd
        beq $v0, 1, lowerd
       
       symbold:
        move $v0, $a0
        b noActiond
       
       upperd:
       	beq $a0, 0x5a, outofb1d
	beq $a0, 0x59, outofb2d
	addi $a0, $a0, 2
	move $v0, $a0
	b noActiond
	
	outofb1d:
	li $a0, 0x42
	move $v0, $a0
	b noActiond
	
	outofb2d:
	li $a0, 0x41
	move $v0, $a0
	b noActiond
	
	lowerd:
	beq $a0, 0x7a, outofb3d
	beq $a0, 0x79, outofb4d
        addi $a0, $a0, 2
	move $v0, $a0
	b noActiond
	
	outofb3d:
	li $a0, 0x62
	move $v0, $a0
	b noActiond
		
	outofb4d:
	li $a0, 0x61
	move $v0, $a0
	b noActiond	
	
        noActiond:
        b exit3

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
	bgt $a0, 0x40, check0
	b notletter
	
	check0:
	  bgt $a0 ,0x5a, check1
	  b uppercase
	 
	check1:
	  bgt $a0, 0x60, check2
	  b notletter
	  
	 check2:
	  bgt $a0, 0x7a, notletter
	  b lowercase
	  
	 uppercase:
	  li $v0, 0
       beq $t8, 0x45, checkee
       beq $t8, 0x44, checked
	 
	 lowercase:
	  li $v0, 1
       beq $t8, 0x45, checkee
       beq $t8, 0x44, checked
	  
	 notletter:
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
       move $t1, $a1 #e
       move $t2, $a0 #d
    	b output1
    decypt:
       move $t1, $a0  #e
       move $t2, $a1 #d
        b output1
        
    output1:
      la $a0, encrypted
      li $v0, 4
      syscall
      
       li $v0, 4
       la $a0, ($t1)
       syscall
      la $a0, newLine
      li $v0, 4
      syscall
     
     output2:
      li $v0, 4
      la $a0, decrypted
      syscall

       li $v0, 4
       la $a0, ($t2)
       syscall
                     
   jr $ra