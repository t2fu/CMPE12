##########################################################################
# Created by: Fu, Tiancheng
# CruzID: tfu6
# 10th February 2019
# Assignment: Lab 3: MIPS Looping ASCII Art
# CMPE 012, Computer Systems and Assembly Language
# UC Santa Cruz, Winter 2019
#
# Description: This program prints ‘Hello world.’ to the screen.
#
# Notes: This program is intended to be run from the MARS IDE.
##########################################################################
.data
	message1: .asciiz "Enter the length of one of the triangle legs: "
	message2: .asciiz "\nEnter the number of triangles to print: "
	newLine: .asciiz "\n"
	Run: .assciiz "Run"
.text
	li $v0, 4
	la $a0, message1
	syscall
	
	li $v0, 5
	syscall
	
	move $t0, $v0

	li $v0, 4
	la $a0, message2
	syscall
	
	li $v0, 5
	syscall
	move $t1, $v0
	
	main:
		addi $t2, $zero, 0 #i
		Loopi:	
			
			beq $t2, $t1, exiti
			addi $t2, $t2, 1
			addi $t3, $zero, 0 #j
			addi $t5, $t0, 0 #l
			
			
		Loopj:	
			beq $t3, $t0, exitj
			addi $t3, $t3, 1
			addi $t4, $zero, 0 #k
			
			li $v0, 4
			la $a0, newLine #print new line
			syscall
			
			Loopk:	
				addi $t6, $zero, 0
				move $t6, $t3
				sub $t6, $t6, 1
				beq $t4, $t6, exitk
				addi $t4, $t4, 1
				
				li $v0, 11
				la $a0, 0x20 #print new space
				syscall				
			
				j Loopk				
			exitk:
				li $v0, 11
				la $a0, 0x5c #print new fsls
				syscall	
				j Loopj
			
			
		exitj:	
			#bne $s1, $t0, addii
			j Loopl
			
		 	#bne $s1, $t0, Loopj
		 	#addi $s2, $s2, 1
		 	#bne $s2, $t0, Loopl
		exiti:
			li $v0, 10
			syscall
		
		Loopl:
			beq $t5, $zero, exitl
			sub $t5, $t5, 1
			addi $t4, $t5, 0 #z
			#sub $t4, $t4, 1
				
			li $v0, 4
			la $a0, newLine #print new line
			syscall

			Loopz:	
				beq $zero, $t4, exitz
				sub $t4, $t4, 1
				
				li $v0, 11
				la $a0, 0x20 #print new space
				syscall				
			
				j Loopz
			exitz:
				li $v0, 11
				li $a0, 0x2f #print new bsls
				syscall	
				j Loopl			
		
		exitl:
			j Loopi
		