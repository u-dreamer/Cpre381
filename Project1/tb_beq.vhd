-------------------------------------------------------------------------
-- L8Sk8rs
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- tb_beq.vhd
-------------------------------------------------------------------------------------------
-- DESCRIPTION: This file contains a testbench for the beq intruction.
-------------------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;  -- For logic types I/O
library std;
use std.textio.all;             -- For basic I/O

-- Usually name your testbench similar to below for clarity tb_<name>
entity tb_beq is
  generic  (gCLK_HPER   : time := 10 ns; -- Generic for half of the clock cycle period
            N : integer := 32);
end tb_beq;

architecture arch of tb_beq is

-- Define the total clock period time
constant cCLK_PER  : time := gCLK_HPER * 2;

-- Component Declaration -----------------------------------------------------------------
  component beq is
    port(i_A 	   : in std_logic_vector(N-1 downto 0);
         i_B       : in std_logic_vector(N-1 downto 0);
         o_Z       : out std_logic_vector(N-1 downto 0));
  end component;

-- SIGNALS -------------------------------------------------------------------------------
signal CLK, reset : std_logic := '0';

--Initialize inputs to 0
signal i_A    : std_logic_vector(N-1 downto 0) := x"00000000";
signal i_B    : std_logic_vector(N-1 downto 0) := x"00000000";

signal o_Z    : std_logic_vector(N-1 downto 0) := x"00000000";

begin

-- Port/Signal Mapping ------------------------------------------------------
  DUT0: beq
  port map( i_A     => i_A,
	    i_B     => i_B,
            o_Z     => o_Z);

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

    -- Test case 1: A > B
    i_A   <= x"FFFFFFFF";
    i_B   <= x"00000000";
    wait for gCLK_HPER*2;
    -- Expect: o_Z = 0x00000001

    -- Test case 2: A < B
    i_A   <= x"00000000";
    i_B   <= x"FFFFFFFF";
    wait for gCLK_HPER*2;
    -- Expect: o_Z = 0x00000001

    -- Test case 3: A = B
    -- Test i_A = 0x0F0F0F0F
    i_A   <= x"0F0F0F0F";
    i_B   <= x"0F0F0F0F";
    wait for gCLK_HPER*2;
    -- Expect: o_Z = 0x00000000

  end process;
end arch;