-------------------------------------------------------------------------
-- Anna Huggins
-- Iowa State University
-------------------------------------------------------------------------
-- fetchUnit.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of a fetch unit
--      	for a MIPS processor.
-------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity fetchUnit is
  generic(N : integer := 32;
          I : integer := 26);
  port ( iCLK         : in std_logic;
         jAddr        : in std_logic_vector(I-1 downto 0);
         pcIn         : in std_logic_vector(N-1 downto 0);
	 branchAddr   : in std_logic_vector(N-1 downto 0);
	 branchEnable : in std_logic;
	 jumpDisable  : in std_logic;
         jrAddr       : in std_logic_vector(N-1 downto 0);
         jrEn         : in std_logic;
	 pcOut	      : out std_logic_vector(N-1 downto 0);
         pcPlusFour   : out std_logic_vector(N-1 downto 0));
end fetchUnit;

architecture structural of fetchUnit is

  component adder_N
    port(iCLK    : in std_logic;
         i_C     : in std_logic;
         i_A     : in std_logic_vector(N-1 downto 0);
         i_B     : in std_logic_vector(N-1 downto 0);
         o_S     : out std_logic_vector(N-1 downto 0);
         o_C     : out std_logic);
  end component;

  component mux2t1_N
    port(i_S          : in std_logic;
         D0           : in std_logic_vector(N-1 downto 0);
         D1           : in std_logic_vector(N-1 downto 0);
         F_OUT        : out std_logic_vector(N-1 downto 0));
  end component;

--- SIGNALS ---------------------------------------------------------------
signal s_pcPlusFour               : std_logic_vector(N-1 downto 0);
signal s_carry0                   : std_logic;
signal s_carry1                   : std_logic;
signal s_shiftedBranchAddr        : std_logic_vector(N-1 downto 0);
signal s_finalJumpAddr            : std_logic_vector(N-1 downto 0);
signal s_jumpMUX                  : std_logic_vector(N-1 downto 0);
signal s_pcPlusBranch		  : std_logic_vector(N-1 downto 0);
signal s_branchMUX                : std_logic_vector(N-1 downto 0);
---------------------------------------------------------------------------

begin

---------------------------------------------------------------------------
-- Level 0: PC + 4
---------------------------------------------------------------------------
  g_Adder0: adder_N
    port MAP(iCLK       => iCLK,
             i_C        => '0',
             i_A        => pcIn,
             i_B        => x"00000004",
             o_S        => s_pcPlusFour,
             o_C        => s_carry0);

             pcPlusFour <= s_pcPlusFour;
---------------------------------------------------------------------------
-- Level 1: PC + BranchAddr
---------------------------------------------------------------------------
  -- Shift BranchAddr left by 2
    s_shiftedBranchAddr <= branchAddr(29 downto 0) & "00";

  g_Adder1: adder_N
    port MAP(iCLK   => iCLK,
             i_C    => '0',
             i_A    => s_pcPlusFour,
             i_B    => s_shiftedBranchAddr,
             o_S    => s_pcPlusBranch,
             o_C    => s_carry1);

---------------------------------------------------------------------------
-- Level 2: Branch OR PC + 4
----------------------------------------------------------------------------
  g_branchMUX: mux2t1_N
    port MAP( i_S          => branchEnable,
              D0           => s_pcPlusFour,
              D1           => s_pcPlusBranch,
              F_OUT        => s_branchMUX);

  -- Shift jump and shtuff...
    s_finalJumpAddr        <= s_pcPlusFour(N-1 downto 28) & jAddr & "00";
---------------------------------------------------------------------------
-- Level 3: To Jump, or not to Jump......
---------------------------------------------------------------------------
    g_jumpMUX: mux2t1_N
    port MAP( i_S          => jumpDisable,
              D0           => s_finalJumpAddr,
              D1           => s_branchMUX,
              F_OUT        => s_jumpMUX);

---------------------------------------------------------------------------
-- Level 4: Jump Reg OR Other
---------------------------------------------------------------------------
    g_jrMUX: mux2t1_N
    port MAP( i_S          => jrEn,
              D0           => s_jumpMUX,
              D1           => jrAddr,
              F_OUT        => pcOut);

end structural;
