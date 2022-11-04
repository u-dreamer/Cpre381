-------------------------------------------------------------------------
-- L8Sk8rs
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- tb_adderSub_N.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a testbench for the N-bit
--              adder-subtractor.
-------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;
library std;
use std.textio.all;

entity tb_addSub_N is
  generic  (gCLK_HPER   : time := 10 ns;
            N : integer := 32);
end tb_addSub_N;

architecture structural of tb_addSub_N is

constant cCLK_PER  : time := gCLK_HPER * 2;

  component adderSub_N is
    port(iCLK      : in std_logic;
         iA        : in std_logic_vector(N-1 downto 0);
         iB        : in std_logic_vector(N-1 downto 0);
         nAdd_Sub  : in std_logic;
         Ov	   : in std_logic;
         o_Sum	   : out std_logic_vector(N-1 downto 0);
         o_C       : out std_logic;
         o_Ov      : out std_logic);
end component;

--- SIGNALS ---------------------------------------------------------------
signal CLK, reset : std_logic := '0';

signal s_iA        :  std_logic_vector(N-1 downto 0) := x"00000000";
signal s_iB        :  std_logic_vector(N-1 downto 0) := x"00000000";
signal s_nAddSub   :  std_logic := '0';

signal s_So        :  std_logic_vector(N-1 downto 0);
signal s_Co        :  std_logic;
signal s_Ovo	   :  std_logic;

---------------------------------------------------------------------------

begin

--- PORT MAP --------------------------------------------------------------
  DUT0: adderSub_N
  port map( iCLK       => CLK,
            iA         => s_iA,
            iB         => s_iB,
            nAdd_Sub   => s_nAddSub,
            Ov         => s_Ovo,
            o_Sum      => s_So,
            o_C        => s_Co);

---- CLOCK STUFF -----------------------------------------------------------
  P_CLK: process
  begin
    CLK <= '1';
    wait for gCLK_HPER;
    CLK <= '0';
    wait for gCLK_HPER;
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

---- TEST CASES -----------------------------------------------------------
  zP_TEST_CASES: process
  begin
    wait for gCLK_HPER/2;

    -- Test case 0: Everything = 0
    -- iA = 0x00000000, iB = 0x00000000, nAdd_Sub = 0, Ov = 0
    s_nAddSub  <= '0';           -- 0 = add, 1 = sub
    s_iA       <= x"00000000";
    s_iB       <= x"00000000";
    s_Ovo      <= '0';           -- 0 = unsigned, 1 = signed
    wait for gCLK_HPER*2;
    -- Expect: o_Sum = 0x00000000
    --         o_Ov  = 0

    -- Test case 1: 1+0 (no overflow)
    -- iA = 0x00000001, iB = 0x00000000, nAdd_Sub = 0, Ov = 0
    s_nAddSub  <= '0';           -- 0 = add, 1 = sub
    s_iA       <= x"00000001";
    s_iB       <= x"00000000";
    s_Ovo      <= '0';           -- 0 = unsigned, 1 = signed
    wait for gCLK_HPER*2;
    -- Expect: o_Sum = 0x00000001
    --         o_Ov  = 0

    -- Test case 2: 2-1 (no overflow)
    -- iA = 0x00000002, iB = 0x00000001, nAdd_Sub = 1, Ov = 0
    s_nAddSub  <= '1';           -- 0 = add, 1 = sub
    s_iA       <= x"00000002";
    s_iB       <= x"00000001";
    s_Ovo      <= '0';           -- 0 = unsigned, 1 = signed
    wait for gCLK_HPER*2;
    -- Expect: o_Sum = 0x00000001
    --         o_Ov  = 0

    -- Test case 3: -13+10 (no overflow, signed)
    -- iA = 0xFFFFFFF3, iB = 0x0000000A, nAdd_Sub = 0, Ov = 1
    s_nAddSub  <= '0';           -- 0 = add, 1 = sub
    s_iA       <= x"FFFFFFF3";
    s_iB       <= x"0000000A";
    s_Ovo      <= '1';           -- 0 = unsigned, 1 = signed
    wait for gCLK_HPER*2;
    -- Expect: o_Sum = 0xFFFFFFFD
    --         o_Ov  = 1

    -- Test case 4: 9+7 (overflow, signed)
    -- iA = 0x00000009, iB = 0x00000007, nAdd_Sub = 0, Ov = 1
    s_nAddSub  <= '0';           -- 0 = add, 1 = sub
    s_iA       <= x"00000009";
    s_iB       <= x"00000007";
    s_Ovo      <= '1';           -- 0 = unsigned, 1 = signed
    wait for gCLK_HPER*2;
    -- Expect: o_Sum = 0b10000 = 0x00000010
    --         o_Ov  = 1

    -- Test case 5: -2+(-5) (overflow, signed, 32-bit)
    -- iA = 0xFFFFFFFE, iB = 0xFFFFFFFB, nAdd_Sub = 1, Ov = 1
    s_nAddSub  <= '1';           -- 0 = add, 1 = sub
    s_iA       <= x"FFFFFFFE";
    s_iB       <= x"FFFFFFFB";
    s_Ovo      <= '1';           -- 0 = unsigned, 1 = signed
    wait for gCLK_HPER*2;
    -- Expect: o_Sum = 0x00000003
    --         o_Ov  = 1

  end process;
end structural;
