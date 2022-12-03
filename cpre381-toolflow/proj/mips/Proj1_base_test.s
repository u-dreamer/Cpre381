# 
# Create   a   test   application   that   makes   use   of   every   required   arithmetic/logical 
# instruction  at  least  once.  The application  need  not  perform  any  particularly  useful 
# task, but it should demonstrate the full functionality of the processor (e.g., sequences 
# of  many  instructions  executed  sequentially,  1  per  cycle  while  data  written  into 
# registers  can  be  effectively  retrieved  and  used  by  later  instructions)

# data section
.data

# code/instruction section
.text

# add!/addi!
# addu!/addiu!

# sub!
# subu!

# (not & nor)!

# xor!/xori!

# and!/andi!
# or!/ori!

# sll!
# srl!
# sra!

# lui!

# slt!/slti!

# repl.qb!

# -----------------

addi  $1,  $0,  1 		# $1 = 0 + 1  =  1
addiu $2,  $1,  1		# $2 = 1 + 1  =  2
add   $1,  $1,  $2		# $1 = 1 + 2  =  3
addu  $2,  $1,  $2		# $2 = 3 + 2  =  5

sub   $2,  $2,  $1		# $2 = 5 - 3  =  2
subu  $1,  $1,  $1		# $1 = 3 - 3  =  0

nor   $1,  $1,  $2		# $1 = ~(0 | 2)  =  1

xori  $2,  $1,  10		# $2 = 1 ^ 10  =  11
xor   $1,  $1,  $2		# $1 = 1 ^ 11  =  10

andi  $2,  $2,  6		# $2 = 11 & 6  =  2
and   $1,  $2,  $1		# $1 = 2 & 10  =  2

ori   $2,  $2,  8		# $2 = 2 | 8  =  10
or    $1,  $1,  $2		# $1 = 2 | 10 =  10

addi  $3,  $0,  1		# $3 = 0 + 1  =  1
sll   $2,  $2,  $3		# $2 = 10 << 1  =  20
srl   $1,  $1,  $3		# $1 = 10 >> 1  =  5
sra   $1,  $1,  $3		# $1 = 5 >> 1   =  2

lui   $2, 5			# $2 = 5

slt   $1, $1, $2		# 2 < 5 = true, so  $1  = 1
slti  $2, $2, 3			# 5 < 3 = false, so $2 = 0

REPL.QB $2, 1			# $2 = 0001 0001 | 0001 0001 | 0001 0001 | 0001 0001  =  286331153 (0xFF)

halt
