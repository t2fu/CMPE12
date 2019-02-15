##########################################################################
# Created by: Fu, Tiancheng
# CruzID: tfu6
# 15th February 2019
# Assignment: Lab 3: MIPS Looping ASCII Art
# CMPE 012, Computer Systems and Assembly Language
# UC Santa Cruz, Winter 2019
#
# Description: This program allows the user to input the number of triangles and the length of one of the triangle's legs.
# Then the program will print out the triangles with the corresponding number of legs and endthe program when the last triangle
# has finished printing.
#
# Notes: This program is intended to be run from the MARS IDE. The user input values have to be integers.
##########################################################################
.data
	message1: .asciiz "Enter the length of one of the triangle legs: "
	message2: .asciiz "\nEnter the number of triangles to print: "
	newLine: .asciiz "\n"
	Run: .assciiz "Run"
.text
	li $v0, 4     # Output the first message
	la $a0, message1
	syscall
	
	li $v0, 5     # Read the user's respond for the first message
	syscall
	move $t0, $v0 # Save the first user input, length of one of the triangle leg, into $t0

	li $v0, 4     # Output the second message
	la $a0, message2
	syscall
	
	li $v0, 5     # Read the user respond for the second message
	syscall
	move $t1, $v0 # Save the second user input, the number of triangles to print, into $t1
	
	main:         # There are 5 for loops, Loopi, Loopj, Loopk, Loopl, Loopz, in this program to print out the triangles
	
		addi $t2, $zero, 0          # Initialize $t2 to 0 as the loop counting variable for Loopi
		
		Loopi:                      # Loopi is use to print out all of the triangles according to user input in $t1
			
			beq $t2, $t1, exiti # Exit Loopi when all triangles according to $t1 have printed out
			addi $t2, $t2, 1    # Add 1 to $t2 everytime when Loopi has been run
			addi $t3, $zero, 0  # Initialize $t3 to 0 as the loop counting variable for Loopj
			addi $t5, $t0, 0    # Initialize $t5 to the value of $t0 as the loop counting variable for Loopl
			
			
		Loopj:                      # Loopj is use to print out the first side of one triangle acording to user input in $t0
			beq $t3, $t0, exitj # Exit Loopj when all legs for the first side according to $t0 have printed out
			addi $t3, $t3, 1    # Add 1 to $t3 everytime when Loopj has been run
			addi $t4, $zero, 0  # Initialize $t4 to 0 as the loop counting variable for Loopk
			
			li $v0, 4	     # Print a new line
			la $a0, newLine
			syscall
			
			Loopk:		            # Loopk is use to print out the spaces before printing one triangle leg for the first side of the triangle
				addi $t6, $zero, 0  # Initialize $t6 to $t3-1 as the Loopk's reference value
				move $t6, $t3
				sub $t6, $t6, 1
				
				beq $t4, $t6, exitk # Exit Loopk when all spaces before a triangle's leg have been printed
				addi $t4, $t4, 1    # Add 1 to $t4 everytime when Loopk has been run
				
				li $v0, 11          # Print new space
				la $a0, 0x20
				syscall
			
				j Loopk				
			exitk:			     # The exit function for Loopk
				li $v0, 11          # Print new forward slash
				la $a0, 0x5c
				syscall
				
				j Loopj		     # Jump back to Loopj
			
			
		exitj:	            # The exit function for Loopj
			j Loopl     # Jump to Loopl to print the second side of a triangle
			
		exiti:		    # The exit function for Loopi
			li $v0, 10  # End the program when all trangles have printed according to $t1
			syscall
		
		Loopl:        		       # Loopl is use to print out the second side of one triangle acording to user input in $t0
			beq $t5, $zero, exitl # Exit Loopl when all legs for the second side according to $t0 have printed out
			sub $t5, $t5, 1       # Subtract 1 to $t5 everytime when Loopl has been run
			addi $t4, $t5, 0      # Initialize $t4 to the value of $t5 as the loop counting variable for Loopz

			li $v0, 4	       # Print new line
			la $a0, newLine
			syscall

			Loopz:		       	       # Loopz is use to print out the spaces before printing one triangle leg for the second side of the triangle
				beq $zero, $t4, exitz # Exit Loopz when all spaces before a triangle's leg have been printed
				sub $t4, $t4, 1       # Subtract 1 to $t4 everytime when Loopl has been run
				
				li $v0, 11	       # Print new space
				la $a0, 0x20
				syscall				
			
				j Loopz		       # Jump back to Loopz
				
			exitz:			       # The exit function for Loopz
				li $v0, 11            # Print new backward slash
				li $a0, 0x2f
				syscall
				j Loopl # Jump back to Loopl
		
		exitl:
			j Loopi # Jump back to Loopi to print the next triangle