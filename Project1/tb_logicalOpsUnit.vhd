-------------------------------------------------------------------------
-- Anna Huggins
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- tb_logicalOpsUnit.vhd
-------------------------------------------------------------------------------------------
-- DESCRIPTION: This file contains a testbench for the N-bit AND gate.
-------------------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;  -- For logic types I/O
library std;
use std.textio.all;             -- For basic I/O

-- Usually name your testbench similar to below for clarity tb_<name>
entity tb_logicalOpsUnit is
  generic  (gCLK_HPER   : time := 10 ns; -- Generic for half of the clock cycle period
            N : integer := 32;
            S : integer := 4);     
end tb_logicalOpsUnit;

architecture arch of tb_logicalOpsUnit is

-- Define the total clock period time
constant cCLK_PER  : time := gCLK_HPER * 2;

-- Component Declaration -----------------------------------------------------------------
  component logicalOpsUnit is
    port(ALUOp     : in std_logic_vector(S-1 downto 0);
         i_A 	   : in std_logic_vector(N-1 downto 0);
         i_B       : in std_logic_vector(N-1 downto 0);
         o_F       : out std_logic_vector(N-1 downto 0));
  end component;

-- SIGNALS -------------------------------------------------------------------------------
signal CLK, reset : std_logic := '0';

--Initialize inputs to 0
signal i_A    : std_logic_vector(N-1 downto 0) := x"00000000";
signal i_B    : std_logic_vector(N-1 downto 0) := x"00000000";
signal ALUOp  : std_logic_vector(S-1 downto 0) := "0000";
signal o_F    : std_logic_vector(N-1 downto 0) := x"00000000";

begin

-- Port/Signal Mapping ------------------------------------------------------
  DUT0: logicalOpsUnit
  port map( ALUOp   => ALUOp,
            i_A     => i_A,
	    i_B     => i_B,
            o_F     => o_F);

-- Clock Stuff -----------------------------------------------------------
  P_CLK: process
  begin
    CLK <= '1';         -- clock starts at 1
    wait for gCLK_HPER; -- after half a cycle
    CLK <= '0';         -- clock becomes a 0 (negative edge)
    wait for gCLK_HPER; -- after half a cycle, process begins evaluation again
  end process;

  P_RST: process
  begin
  	reset <= '0';   
    wait for gCLK_HPER/2;
	reset <= '1';
    wait for gCLK_HPER*2;
	reset <= '0';
	wait;
  end process;  
  
-- Test Cases ---------------------------------------------------------------

  P_TEST_CASES: process
  begin
    wait for gCLK_HPER/2; -- for waveform clarity, I prefer not to change inputs on clk edges

-- NOT Tests -----------------------------------------------------------------
    -- Test case 0: NOT Gate 
    ALUOp <= "0000";
    i_A   <= x"00000000"; -- Should be inverted
    i_B   <= x"FFFF0000"; -- Should be ignored (for NOT)
    wait for gCLK_HPER*2;
    -- Expect: o_F = 0xFFFFFFFF

    -- Test case 1: NOT Gate 
    ALUOp <= "0000";
    i_A   <= x"F0F01111"; -- Should be inverted
    i_B   <= x"FFFFFFFF"; -- Should be ignored (for NOT)
    wait for gCLK_HPER*2;
    -- Expect: o_F = 0x0F0FEEEE

-- XOR Tests -----------------------------------------------------------------
    -- Test case 2: XOR Gate 
    ALUOp <= "0001";
    i_A   <= x"00000000"; -- Should be XOR'd with i_B
    i_B   <= x"FFFF0000"; 
    wait for gCLK_HPER*2;
    -- Expect: o_F = 0xFFFF0000

    -- Test case 3: XOR Gate 
    ALUOp <= "0001";
    i_A   <= x"10101010"; -- Should be XOR'd with i_B
    i_B   <= x"33333333"; 
    wait for gCLK_HPER*2;
    -- Expect: o_F = 0x23232323

-- OR Tests -----------------------------------------------------------------
    -- Test case 4: OR Gate 
    ALUOp <= "0010";
    i_A   <= x"00000000"; -- Should be OR'd with i_B
    i_B   <= x"FFFF0000"; 
    wait for gCLK_HPER*2;
    -- Expect: o_F = 0xFFFF0000

    -- Test case 5: OR Gate 
    ALUOp <= "0010";
    i_A   <= x"10101010"; -- Should be OR'd with i_B
    i_B   <= x"33333333"; 
    wait for gCLK_HPER*2;
    -- Expect: o_F = 0x33333333

-- NOR Tests -----------------------------------------------------------------
    -- Test case 6: NOR Gate 
    ALUOp <= "0011";
    i_A   <= x"00000000"; -- Should be NOR'd with i_B
    i_B   <= x"FFFF0000"; 
    wait for gCLK_HPER*2;
    -- Expect: o_F = 0x0000ffff

    -- Test case 7: NOR Gate 
    ALUOp <= "0011";
    i_A   <= x"10101010"; -- Should be NOR'd with i_B
    i_B   <= x"33333333"; 
    wait for gCLK_HPER*2;
    -- Expect: o_F = 0xCCCCCCCC

-- AND Tests -----------------------------------------------------------------
    -- Test case 8: AND Gate 
    ALUOp <= "0100";
    i_A   <= x"FF000000"; -- Should be AND'd with i_B
    i_B   <= x"FFFF0000"; 
    wait for gCLK_HPER*2;
    -- Expect: o_F = 0xFF000000

    -- Test case 9: AND Gate 
    ALUOp <= "0100";
    i_A   <= x"10101010"; -- Should be AND'd with i_B
    i_B   <= x"33333333"; 
    wait for gCLK_HPER*2;
    -- Expect: o_F = 0x10101010

-- SLT Tests -----------------------------------------------------------------
    -- Test case 10: SLT
    ALUOp <= "0101";
    i_A   <= x"00000000"; -- If 0 < -65536, o_F = 1
    i_B   <= x"FFFF0000"; 
    wait for gCLK_HPER*2;
    -- Expect: o_F = 0x00000000

    -- Test case 11: SLT
    ALUOp <= "0101";
    i_A   <= x"FFFFFF01"; -- If -255 < 0, o_F = 1
    i_B   <= x"00000000"; 
    wait for gCLK_HPER*2;
    -- Expect: o_F = 0xCCCCCCCC

-- Repl.qb Tests -------------------------------------------------------------

    -- Test case 12: repl.qb
    ALUOp <= "0110";
    i_B   <= x"000022F1";
    wait for gCLK_HPER*2;
    -- Expect: o_F = 0xF1F1F1F1

    -- Test case 13: repl.qb
    ALUOp <= "0110";
    i_B   <= x"00000321";
    wait for gCLK_HPER*2;
    -- Expect: o_F = 0x21212121

  
  end process;
end arch;