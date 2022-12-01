-------------------------------------------------------------------------
-- L8 Sk8rs
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
  generic(N : integer := 32;
          C : integer := 22;
	  F : integer := 6);
  port ( instr	      : in std_logic_vector(N-1 downto 0);
         controlOut   : out std_logic_vector(C-1 downto 0));
end controlUnit;

architecture dataflow of controlUnit is
-- SIGNALS ------------------------------------------------------------------------------
signal s_RTYPE  : std_logic_vector(C-1 downto 0);
signal funcCode : std_logic_vector(F-1 downto 0);
signal opCode   : std_logic_vector(F-1 downto 0);
signal shamt   : std_logic_vector(4 downto 0);
-----------------------------------------------------------------------------------------

begin

-----------------------------------------------------------------------------------------
-- Control Bits Explained:
--   X     X      X    X    X     X      X	 X       X       X	 X	 X   
--  21    20     19   18   17    16     15      14      13      12	11	10    
-- Halt SignExt Jump Jal JReg RegDst RegWrite Branch MemToReg MemRead MemWrite ALUSrc 
-----------------------------------------------------------------------------------------
--    X  X  X  X  X      X       X         X    X    X
--    9  8  7  6  5      4       3         2    1    0
--   [    shamt    ] [Pick ALU Output] [Operation Controls]
-----------------------------------------------------------------------------------------
-- Our R-Type instructions:
-- add, addu, and, not, nor, xor, or, slt, sll, srl, sra, sub, subu, jr
-----------------------------------------------------------------------------------------

funcCode <= instr(5 downto 0);
opCode   <= instr(31 downto 26);
shamt    <= instr(10 downto 6);

 with funcCode select s_RTYPE <=


   "0010011000000000000010" when "100000", -- add
   "0010011000000000000000" when "100001", -- addu

   "0010011000000000000100" when "100100", -- and
   "0010011000000000010000" when "000001", -- not
   "0010011000000000010011" when "100111", -- nor
   "0010011000000000010001" when "100110", -- xor
   "0010011000000000010010" when "100101", -- or
   "0010011000000000010101" when "101010", -- slt

   "001001100000" & shamt & "01001" when "000000", -- sll
   "001001100000" & shamt & "01000" when "000010", -- srl
   "001001100000" & shamt & "01010" when "000011", -- sra

   "0010011000000000000011" when "100010", -- sub
   "0010011000000000000001" when "100011", -- subu

   "0000100000000000000000" when "001000", -- jr
   "0111111111111111111111" when others;


 with opCode select controlOut <= 
   s_RTYPE when "000000",       	  -- R-Type instructions depend on their Function code
					  -- which are fed into the ALUControlUnit
   "1000000000000000000000" when "010100", -- halt
   "0110001000010000000010" when "001000", -- addi 
   "0110001000010000000000" when "001001", -- addiu	

   "0010001000010000000100" when "001100", -- andi
   "0010001000000000010111" when "001111", -- lui

   "0110001011010000000000" when "100011", -- lw

   "0010001000010000010001" when "001110", -- xori
   "0010001000010000010010" when "001101", -- ori
   "0110001000010000010101" when "001010", -- slti

   "0110000000110000000000" when "101011", -- sw	

   "0010000100000000000001" when "000100", -- beq
   "0010000100000000000000" when "000101", -- bne

   "0000000000000000000000" when "000010", -- j
   "0001000000000000000000" when "000011", -- jal

   "0010011000010000010110" when "010010", -- repl.qb

   "0111111111111111111111" when others;

end dataflow;
							
  	 
