##########################################################################
# Created by: Fu, Tiancheng
# CruzID: tfu6
# 19 February 2019
#
# Assignment: Lab 4: ASCII Conversion
# CMPE 012, Computer Systems and Assembly Language
# UC Santa Cruz, Winter 2019
#
# Description: This program read two 8-bit 2'S Complement number and will add them to a sum and output it
#
# Notes: This program is intended to be run from the MARS IDE. These numbers may be entered as hex
# (using the “0x” prefix) or binary (using the “0b” prefix). The range of these
# inputs are: [0x80, 0x7F] in hex or [0b10000000, 0b01111111] in binary. Note
# that this range is [-128, 127] in decimal.
##########################################################################

# Pseudocode:
# 
# This program read two 8-bit 2'S Complement number then add them together in 2SC and output the sum
# The user input will be entered as either as hex "0x" or binary number "0b"
# 
# main function .text
# ask for user input
#
# if input start with "0x" -> BitConverter1
# 	output the user's input
#		convert the first input to 32-bit 2SC binary number and store it in $s1
#		convert the second input to 32-bit 2SC binary number and store it in $s2
#			
# if input start with "0b" -> BitConverter2
# 	output the user's input
#		convert the first input to 32-bit 2SC binary number and store it in $s1
#		convert the second input to 32-bit 2SC binary number and store it in $s2
#
# function BitConverter1:
#	This function convert a 2 digits 2SC hex string into a 2SC binary value
#	Sign-extend the binary number to 32-bit
#	to BinaryAdder
#
# function BitConverter2:
#	This function sign-extend the user input to a 32-bit 2SC value
#	to BinaryAdder
#
# function BinaryAdder:
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