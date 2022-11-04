-------------------------------------------------------------------------
-- Anna Huggins
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- tb_controlUnit.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a testbench for the fetch unit.
-------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;  -- For logic types I/O
library std;
use std.textio.all;             -- For basic I/O

entity tb_controlUnit is
  generic  (gCLK_HPER   : time := 10 ns); -- Generic for half of the clock cycle period  
end tb_controlUnit;

architecture arch of tb_controlUnit is
-- Define the total clock period time
constant cCLK_PER  : time := gCLK_HPER * 2;

-- Component Declaration --------------------------------------------------------------
  component controlUnit is
    port(opCode       : in std_logic_vector(5 downto 0);
         controlOut   : out std_logic_vector(12 downto 0));
end component;

-- SIGNALS ---------------------------------------------------------------------------
signal CLK, reset : std_logic := '0';

-- Initialize inputs to 0
signal s_opCode          : std_logic_vector(5 downto 0) := "000000";
signal s_controlOut      : std_logic_vector(12 downto 0) := "0000000000000";

begin

-- Port/Signal Mapping ------------------------------------------------------
  DUT0: controlUnit
  port map( opCode         => s_opCode,
            controlOut     => s_controlOut);

---- Clock stuff -----------------------------------------------------------
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
-------------------------------------------------------------------------------

  P_TEST_CASES: process
  begin
    wait for gCLK_HPER/2; -- for waveform clarity, I prefer not to change inputs on clk edges
    wait for gCLK_HPER*2;

    -- Test case 0: opCode = 000000
    s_opCode         <= "000000";
    wait for gCLK_HPER*2;
    -- Expect: controlOut = 0100110000010

    -- Test case 1: opCode = 010000
    s_opCode         <= "010000";
    wait for gCLK_HPER*2;
    -- Expect: controlOut = 1100010000100

    -- Test case 2: opCode = 001111
    s_opCode         <= "001111";
    wait for gCLK_HPER*2;
    -- Expect: controlOut = 0100010000100

  end process;
end arch;