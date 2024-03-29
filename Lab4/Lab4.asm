##########################################################################
# Created by: Fu, Tiancheng
# CruzID: tfu6
# 3rd March 2019
#
# Assignment: Lab 4: ASCII Conversion
# CMPE 012, Computer Systems and Assembly Language
# UC Santa Cruz, Winter 2019
#
# Description: This program read two 8-bit 2'S Complement number and will add them to a sum and output it. The program will convert the two input arguments
# into 32-bit sign extend 2's Complement number and store them in register $s1 and $s2. Then the program will add the value stores in the register $s1
# and $s2 into $s0 and output the sum in base 4 with a magnitude and a negative sign if the sum is negative.
#
# Notes: This program is intended to be run from the MARS IDE. These numbers may be entered as hex
# (using the �0x� prefix) or binary (using the �0b� prefix). The range of these
# inputs are: [0x80, 0x7F] in hex or [0b10000000, 0b01111111] in binary. Note
# that this range is [-128, 127] in decimal. Input arguments out of the range may
# result in runtime errors.
##########################################################################

# Pseudocode:
# 
# This program read two 8-bit 2'S Complement number then add them together in 2SC and output the sum
# The user input will be entered as either as hex "0x" or binary number "0b"
# 
# main function .text
# ask for user input
#
# if input start with "0x" -> BitConverter1 or BinaryA
# 	output the user's input
#		convert the first input to 32-bit 2SC binary number and store it in $s1
#		convert the second input to 32-bit 2SC binary number and store it in $s2
#			
# if input start with "0b" -> BitConverter2 or BinaryB
# 	output the user's input
#		convert the first input to 32-bit 2SC binary number and store it in $s1
#		convert the second input to 32-bit 2SC binary number and store it in $s2
#
# function BitConverterA:
#	This function convert a 2 digits 2SC hex string into a 2SC binary value
#	Sign-extend the binary number to 32-bit and save the value in register $s1
#	to BinaryAdder
#
# function BitConverterB:
#	This function convert a 2 digits 2SC hex string into a 2SC binary value
#	Sign-extend the binary number to 32-bit and save the value in register $s2
#	to BinaryAdder
#
# function BinaryA:
#	This function convert a 8 digits binary string into a 2SC binary value
#	Sign-extend the binary number to 32-bit and save the value in register $s1
#	to BinaryAdder
#
# function BinaryB:
#	This function convert a 8 digits binary string into a 2SC binary value
#	Sign-extend the binary number to 32-bit and save the value in register $s2
#	to BinaryAdder
#
# function BitAdder:
#	This function add value in register $s1 and $s2
#		store the sum to $s0
#			to SignAdder
# 
# function SignAdder:
#	Convert the magnitude to base 4
# 	If the value in $s0 start with a 1
#		Output a "-" sign before outputing the magnitude
#	If the value in $s0 start with a 0
#		Output the magnitude without any sign
# 
# End the program after output the result
##########################################################################
.data
	message1: .asciiz "You entered the numbers:"
	message2: .asciiz "The sum in base 4 is:"
	newLine: .asciiz "\n"
	H: .asciiz "\nHex"
	B: .asciiz "\nBinary"

#main
.text
	add $t0, $zero, $a1 # Counting register count how many time the main has runned
	lw $t1, ($t0)       #loading the starting memory location of the first argument into $t1
	lw $t2, 4($t0)      #loading the starting memory location of the 2nd argument into $t2
	li $v0, 4	
	li $v0, 4           # Output the first message
	la $a0, message1
	syscall
	li $v0, 4
	la $a0, newLine
	syscall
	
	li $v0, 4
	la $a0, ($t1)       # Save first input argument
	syscall
	
	li $v0, 11
	la $a0, ' '
	syscall
	
	li $v0, 4
	la $a0, ($t2)       # Save second input argument
	syscall
	
	li $v0, 4
	la $a0, newLine
	syscall
	
	li $v0, 4
	la $a0, newLine
	syscall
	
	li $v0, 4           # Output the second message
	la $a0, message2
	syscall
	
	addi $t6, $zero, 0  # Counting register count how many time the main has runned
	
	BitChecker:            #Check if the input argument is in binary or hexadecimal (hex)
		lb $t5, 1($t1) #Check the first input argument
		addi $t7, $zero, 0
		beq $t5, 120, bitConverterHexA
		beq $t5, 98, binaryA
		
		jp1:	    #Check the second input argument
		
		lb $t5, 1($t2)
		beq $t5, 120, bitConverterHexB
		beq $t5, 98, binaryB
##################################################################################
	jp5:
	   
	   add $s0, $s1, $s2  # Add the value in register $s1 and $s2 into the sum register $s0

	   li $v0, 4
	   la $a0, newLine
	   syscall
	   
	   move $t6, $s0
	   bltz $s0, negSign
	   j jpB
	   
	   negSign:          # Output a negative sign before the magnitude if the sum is negative
	   li $v0, 11
	   la $a0, 45
	   syscall
	   
	   not $t6, $t6
	   addi $t6, $t6, 1
	   
	   jpB:		      # Divide the sum by 4 and save the remainders
	   div $t6, $t6, 4
	   mfhi $t3

	   div $t6, $t6, 4
	   mfhi $t4
	   	
	   # div $t0 4
	   div $t6, $t6, 4
	   mfhi $t7
	   
	   div $t6, $t6, 4
	   mfhi $t8

	   div $t6, $t6, 4
	   mfhi $t9
	   
	   addi $t3, $t3, 48 # Add the Ascii values into the remainders
	   addi $t4, $t4, 48
	   addi $t7, $t7, 48
	   addi $t8, $t8, 48
	   addi $t9, $t9, 48
	   
	   beq, $t9, 48, output2  # Output the remainders to form the sum in base 4
	   
	   li $v0, 11
	   la $a0, ($t9)
	   syscall
	   
	   output2:
	   bne $t9, $t8, outA
	   beq, $t8, 48, output3
	   outA:
	   li $v0, 11
	   la $a0, ($t8)
	   syscall
	   
	   output3:
	   bne $t9, $t7, outB
	   beq, $t7, 48, output0
	   outB:
	   li $v0, 11
	   la $a0, ($t7)
	   syscall
	   
	   output0:
	   bne $t9, $t4, outC
	   beq, $t4, 48, output1
	   outC:
	   li $v0, 11
	   la $a0, ($t4)
	   syscall
	   
	   output1:
	   bne $t9, $t3, outD
	   beq, $t3, 48, end
	   outD:
	   li $v0, 11
	   la $a0, ($t3)
	   syscall
	   	   
	   end:
	   li $v0, 4
	   la $a0, newLine
	   syscall
	   
	   j exit

##################################################################################
	bitConverterHexA:          # Convert the first input argument hex number into 32-bit sign extend value and save it into register $s1
		addi $t6, $zero, 0
		addi $t7, $zero, 1
		li $s1, 0
		lb $t5, 3($t1)
		jp2:	           # Convert hex value to decimal value
		beq $t5, 48, C0
		beq $t5, 49, C0
		beq $t5, 50, C0
		beq $t5, 51, C0
		beq $t5, 52, C0
		beq $t5, 53, C0
		beq $t5, 54, C0
		beq $t5, 55, C0
		beq $t5, 56, C0
		beq $t5, 57, C0
		beq $t5, 65, C10
		beq $t5, 66, C10
		beq $t5, 67, C10
		beq $t5, 68, C10
		beq $t5, 69, C10
		beq $t5, 70, C10
		
		   C0:
		   sub $t5, $t5 48
		   mul $t5, $t7, $t5
		   j out1

		   C10:
		   sub $t5, $t5 55
		   mul $t5, $t7, $t5
		   j out1
		 
	  out1:			      # Convert the decimal value to 32-bit sign extend value by shifting the value left and right by 24-bit
	 	add $s1, $s1, $t5
	        addi $t6, $t6, 1
		la $t7, 16
		lb $t5, 2($t1)
		beq $t6, 1, jp2
		
		sll $s1, $s1, 24
		sra $s1, $s1, 24
	        j EndCheckerA
	        
	EndCheckerA:
	j jp1		
	
	bitConverterHexB:	      # Convert the second input argument hex number into 32-bit sign extend value and save it into register $s2; use the same logic as bitConverterHexA
		addi $t6, $zero, 0
		addi $t7, $zero, 1
		li $s2, 0
		lb $t5, 3($t2)
		
		jp3:	             # Convert hex value to decimal value
		beq $t5, 48, C0B
		beq $t5, 49, C0B
		beq $t5, 50, C0B
		beq $t5, 51, C0B
		beq $t5, 52, C0B
		beq $t5, 53, C0B
		beq $t5, 54, C0B
		beq $t5, 55, C0B
		beq $t5, 56, C0B
		beq $t5, 57, C0B
		beq $t5, 65, C10B
		beq $t5, 66, C10B
		beq $t5, 67, C10B
		beq $t5, 68, C10B
		beq $t5, 69, C10B
		beq $t5, 70, C10B
		
		   C0B:
		   sub $t5, $t5 48
		   mul $t5, $t7, $t5
		   j out2

		   C10B:
		   sub $t5, $t5 55
		   mul $t5, $t7, $t5
		   j out2
		   
		   
	  out2:			    # Convert the decimal value to 32-bit sign extend value by shifting the value left and right by 24-bit
	 	add $s2, $s2, $t5
	        addi $t6, $t6, 1
		la $t7, 16
		lb $t5, 2($t2)
		beq $t6, 1, jp3
		
		sll $s2, $s2, 24
		sra $s2, $s2, 24
	        j EndCheckerB
	        
	EndCheckerB:
	j jp5												
##################################################################################	
	binaryA:                                   #Convert second input argument binary value into 32-bit sign extend value and store it into register $s1
		addi $t6, $zero, 0
		addi $t7, $zero, 1
		li $s1, 0
		lb $t5, 9($t1)
		jbA:                               # Convert hex value to decimal value
		beq $t5, 48, B1
		beq $t5, 49, B2
		
		   B1:
		   sub $t5, $t5 48
		   mul $t5, $t7, $t5
		   j outBA

		   B2:
		   sub $t5, $t5 48
		   mul $t5, $t7, $t5
		   j outBA
		 
	  outBA:	
	 	add $s1, $s1, $t5
	        addi $t6, $t6, 1
		mul $t7, $t7, 2
		
		lb $t5, 8($t1)
		beq $t6, 1, jbA
		lb $t5, 7($t1)
		beq $t6, 2, jbA
		lb $t5, 6($t1)
		beq $t6, 3, jbA
		lb $t5, 5($t1)
		beq $t6, 4, jbA
		lb $t5, 4($t1)
		beq $t6, 5, jbA
		lb $t5, 3($t1)
		beq $t6, 6, jbA
		lb $t5, 2($t1)
		beq $t6, 7, jbA
						
		sll $s1, $s1, 24    		   # Convert the decimal value to 32-bit sign extend value by shifting the value left and right by 24-bit
		sra $s1, $s1, 24
		
	        j endBA
	
	endBA:
		j jp1
		
	binaryB:				  # Convert first input argument binary value into 32-bit sign extend value and store it into register $s2; use the same logic as binaryA
		li $t6, 0
		addi $t7, $zero, 1
		li $s2, 0
		lb $t5, 9($t2)
		jbB:
		beq $t5, 48, BB1
		beq $t5, 49, BB2
		
		   BB1:
		   sub $t5, $t5 48
		   mul $t5, $t7, $t5
		   j outBB

		   BB2:
		   sub $t5, $t5 48
		   mul $t5, $t7, $t5
		   j outBB
		 
	  outBB:	
	 	add $s2, $s2, $t5
	       addi $t6, $t6, 1
		mul $t7, $t7, 2
		
		lb $t5, 8($t2)
		beq $t6, 1, jbB
		lb $t5, 7($t2)
		beq $t6, 2, jbB
		lb $t5, 6($t2)
		beq $t6, 3, jbB
		lb $t5, 5($t2)
		beq $t6, 4, jbB
		lb $t5, 4($t2)
		beq $t6, 5, jbB
		lb $t5, 3($t2)
		beq $t6, 6, jbB
		lb $t5, 2($t2)
		beq $t6, 7, jbB
		
		sll $s2, $s2, 24               # Convert the decimal value to 32-bit sign extend value by shifting the value left and right by 24-bit
		sra $s2, $s2, 24
		
	        j endBB
	
	endBB:
		j jp5
##################################################################################
	exit:                                      # End the program after output the sum in base 4
		li $v0 10
		syscall
