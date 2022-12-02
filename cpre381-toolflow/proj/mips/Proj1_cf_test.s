# 
# Create   and   test   an   application   which   uses   each   of   the   required   control-
# flow instructions and has a call depth of at least 5 (i.e., the number of activation records 
# on the stack is at least 4).

# Required control flow instructions:
# branching: bne, beq
# jumping: jr, jal, j                           

# data section
.data

# code/instruction section
.text


# I think I want to make a loop for bne/beq,
# I will also need to figure out what address(es) I want to jump to (jr) and when to use jal

addi  $4,  $0,  5 		# Place “5” in $4/$a0
addi  $5,  $0,  0		# Place "0" in $5/$a1
j beqLoop			# Jump to beqLoop addr.


#Should loop until $4 = 0, then branch to bneLoop
beqLoop:
beq   $4,  $5,  bneLoop		# If $4 = 0, branch to bneLoop
addi  $8,  $8,  1	 	# Arbitrarily add 1 to $8/$t0



bneLoop:
 

addi  $2,  $0,  2		# Place “2” in $2
addi  $3,  $0,  3		# Place “3” in $3
addi  $4,  $0,  4		# Place “4” in $4
addi  $5,  $0,  5		# Place “5” in $5
addi  $6,  $0,  6		# Place “6” in $6
addi  $7,  $0,  7		# Place “7” in $7
addi  $8,  $0,  8		# Place “8” in $8
addi  $9,  $0,  9		# Place “9” in $9
addi  $10, $0,  10		# Place “10” in $10
add   $11, $1,  $2		# $11 = $1 + $2
sub   $12, $11, $3 		# $12 = $11 - $3
add   $13, $12, $4		# $13 = $12 + $4
sub   $14, $13, $5		# $14 = $13 - $5
add   $15, $14, $6		# $15 = $14 + $6
sub   $16, $15, $7		# $16 = $15 - $7
add   $17, $16, $8		# $17 = $16 + $8
sub   $18, $17, $9		# $18 = $17 - $9
add   $19, $18, $10 		# $19 = $18 + $10
addi  $20, $0,  35		# Place “35” in $20
add   $21, $19, $20	 	# $21 = $19 + $20

halt
