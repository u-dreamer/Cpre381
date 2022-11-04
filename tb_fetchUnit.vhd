-------------------------------------------------------------------------
-- Anna Huggins
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- tb_fetchUnit.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a testbench for the fetch unit.
-------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;  -- For logic types I/O
library std;
use std.textio.all;             -- For basic I/O

entity tb_fetchUnit is
  generic  (gCLK_HPER   : time := 10 ns; -- Generic for half of the clock cycle period
            N : integer := 32;
            I : integer := 26);     
end tb_fetchUnit;

architecture arch of tb_fetchUnit is
-- Define the total clock period time
constant cCLK_PER  : time := gCLK_HPER * 2;

-- Component Declaration --------------------------------------------------------------
  component fetchUnit is
    port(iCLK         : in std_logic;
         jAddr        : in std_logic_vector(I-1 downto 0);
         pcIn         : in std_logic_vector(N-1 downto 0);
	 branchAddr   : in std_logic_vector(N-1 downto 0);
	 branchEnable : in std_logic;
	 jumpDisable  : in std_logic;
         jrAddr       : in std_logic_vector(N-1 downto 0);
         jrEn         : in std_logic;
	 pcOut	      : out std_logic_vector(N-1 downto 0);
         pcPlusFour   : out std_logic_vector(N-1 downto 0));
end component;

-- SIGNALS ---------------------------------------------------------------------------
signal CLK, reset : std_logic := '0';

-- Initialize inputs to 0
signal s_jAddr	       : std_logic_vector(I-1 downto 0) := "00000000000000000000000000";
signal s_pcIn	       : std_logic_vector(N-1 downto 0) := x"00000000";
signal s_branchAddr    : std_logic_vector(N-1 downto 0) := x"00000000";
signal s_branchEnable  : std_logic := '0';
signal s_jumpDisable   : std_logic := '0';
signal s_jrAddr        : std_logic_vector(N-1 downto 0) := x"00000000";
signal s_jrEn          : std_logic := '0';

signal s_pcOut	       : std_logic_vector(N-1 downto 0);
signal s_pcPlusFour    : std_logic_vector(N-1 downto 0);

begin

-- Port/Signal Mapping ------------------------------------------------------
  DUT0: fetchUnit
  port map( iCLK         => CLK,
            jAddr        => s_jAddr,
            pcIn         => s_pcIn,
	    branchAddr   => s_branchAddr,
	    branchEnable => s_branchEnable,
	    jumpDisable  => s_jumpDisable,
            jrAddr       => s_jrAddr,
            jrEn         => s_jrEn,

	    pcOut	 => s_pcOut,
            pcPlusFour   => s_pcPlusFour);


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

    -- Test case 0: let pcPlusFour get thru
    s_jAddr         <= "00000000000000000000000000";
    s_pcIn	   <= x"10010000";                  -- current PC address
    s_branchAddr    <= x"10010008";
    s_branchEnable  <= '0';                          -- Enable branch
    s_jumpDisable   <= '1';                          -- Disable jump
    s_jrAddr        <= x"1001000F";
    s_jrEn          <= '0';		            -- Enable jump reg
    wait for gCLK_HPER*2;
    -- Expect: pcOut = 0x10010004
    -- Expect: pcPlusFour = 0x10010004

    -- Test case 1: let PCPlusBranch get thru
    s_jAddr         <= "00000000000000000000000000";
    s_pcIn	    <= x"10010000";                  -- current PC address
    s_branchAddr    <= x"00000001";
    s_branchEnable  <= '1';                          -- Enable branch
    s_jumpDisable   <= '1';                          -- Disable jump
    s_jrAddr        <= x"00000000";
    s_jrEn          <= '0';		             -- Enable jump reg
    wait for gCLK_HPER*2;
    -- Expect: pcOut = 0x10010004
    -- Expect: pcPlusFour = 0x10010004

    -- Test case 2: let jReg get thru
    s_jAddr         <= "00000000000000000000000000";
    s_pcIn	    <= x"10010000";                  -- current PC address
    s_branchAddr    <= x"00000000";
    s_branchEnable  <= '0';                          -- Enable branch
    s_jumpDisable   <= '1';                          -- Disable jump
    s_jrAddr        <= x"FFFFFFFF";
    s_jrEn          <= '1';		             -- Enable jump reg
    wait for gCLK_HPER*2;
    -- Expect: pcOut = 0x10010004
    -- Expect: pcPlusFour = 0x10010004

  end process;
end arch;