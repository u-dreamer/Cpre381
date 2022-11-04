-------------------------------------------------------------------------
-- Anna Huggins
-- Iowa State University
-------------------------------------------------------------------------
-- controlUnit.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of a control unit
--      	for a MIPS processor.
-------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity controlUnit is
  port ( opCode     : in std_logic_vector(5 downto 0);
         controlOut : out std_logic_vector(12 downto 0));
end controlUnit;

architecture dataflow of controlUnit is
begin

-----------------------------------------------------------------------------------------
-- Control Bits Explained:
--     X      X    X   X    X      X	    X       X 	     X	     X	     X      XX
--    12     11   10   9    8      7        6       5	     4	     3	     2     1-0
--  SignExt Jump Jal JReg RegDst RegWrite Branch MemToReg MemRead MemWrite ALUSrc ALUOp
-----------------------------------------------------------------------------------------
-- ALUOp:
--  00 = add (lw, sw)
--  01 = sub (beq, bne?)
--  10 = R-Type, use func field
--  11 = ...?
-----------------------------------------------------------------------------------------
-- Our R-Type instructions:
-- add, addu, and, not, nor, xor, or, slt, sll, srl, sra, sub, jr
-- repl.qb???
-----------------------------------------------------------------------------------------

--> Use op code to tell ALu what to do...?????? I have no idea tbh and that's a massive L
-- *May need to add a control bit to determine what the ALUControl should read from!

 with opCode select controlOut <= 
   "0100110000010" when "000000", -- R-Type instructions depend on their Function code
				  -- which are fed into the ALUControlUnit

   "1100010000100" when "010000", -- addi 
   "1100010000100" when "010001", -- addiu	

   "0100010000100" when "001100", -- andi
   "0100010000100" when "001111", -- lui

   "1100010110100" when "100011", -- lw
   "0100010001100" when "101011", -- sw	

   "0100010000100" when "001110", -- xori -> How to tell ALU to do xori instead or ori??
   "0100010000100" when "001101", -- ori

   "1100010000100" when "001010", -- slti

   "0100001000001" when "000100", -- beq
   "0100001000001" when "000101", -- bne

   "0000000000000" when "000010", -- j
   "0010010000100" when "000011", -- jal
   "0000000000000" when "001000", -- repl.qb
   "1111111111111" when others;
end dataflow;
							
  	 
