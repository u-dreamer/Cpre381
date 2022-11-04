-------------------------------------------------------------------------
-- Anna Huggins
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- MIPS_Reg_AdderSub1.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file is the implementation of an adder-subtractor
--              with a MIPS reg file.
--              
-- 09/09/2022
-------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity MIPS_Reg_AdderSub1 is
      generic(N : integer := 32;
              X : integer := 5);
      port(i_CLK        : in std_logic;
           i_RST        : in std_logic;
           WE           : in std_logic;
           nAdd_Sub     : in std_logic;
           ALUSrc       : in std_logic;
           rd 	        : in std_logic_vector(X-1 downto 0);
	   rs 	        : in std_logic_vector(X-1 downto 0);
  	   rt           : in std_logic_vector(X-1 downto 0);
           imm          : in std_logic_vector(N-1 downto 0);
           o_Sum	: out std_logic_vector(N-1 downto 0);
           o_C          : out std_logic);
end MIPS_Reg_AdderSub1;

architecture structure of MIPS_Reg_AdderSub1 is
  component MIPS_Reg_File1
    port(i_CLK	   : in std_logic;
	 i_RST     : in std_logic;
	 WE        : in std_logic;
	 i_D       : in std_logic_vector(N-1 downto 0);
         rd 	   : in std_logic_vector(X-1 downto 0);
	 rs 	   : in std_logic_vector(X-1 downto 0);
  	 rt        : in std_logic_vector(X-1 downto 0);
	 rs_val    : out std_logic_vector(N-1 downto 0);
	 rt_val    : out std_logic_vector(N-1 downto 0));	
  end component;

  component adderSub_N
    port(iCLK           : in std_logic;
         iA             : in std_logic_vector(N-1 downto 0);
         iB             : in std_logic_vector(N-1 downto 0);
         imm 	      : in std_logic_vector(N-1 downto 0);
         ALUSrc         : in std_logic;
         nAdd_Sub       : in std_logic;
         o_Sum          : out std_logic_vector(N-1 downto 0);
         o_C            : out std_logic);
  end component;

--- SIGNALS ---------------------------------------------------------------
signal s_rs : std_logic_vector(N-1 downto 0);
signal s_rt : std_logic_vector(N-1 downto 0);
---------------------------------------------------------------------------

begin

---------------------------------------------------------------------------
-- Level 0: MIPS Register File
---------------------------------------------------------------------------
g_MIPS_Reg_File: MIPS_Reg_File1
   port MAP(i_CLK     => i_CLK,
	    i_RST     => i_RST,
	    WE        => WE,
	    i_D       => o_Sum,
            rd 	      => rd,
	    rs 	      => rs,
  	    rt        => rt,
	    rs_val    => s_rs,
	    rt_val    => s_rt);

---------------------------------------------------------------------------
-- Level 1: AdderSub
---------------------------------------------------------------------------
 g_AdderSub: AdderSub_N
   port MAP(iCLK      => i_CLK,
            iA        => s_rs,
            iB        => s_rt,
            imm       => imm,
            ALUSrc    => ALUSrc,
            nAdd_Sub  => nAdd_Sub,
            o_Sum     => o_Sum,
            o_C       => o_C);
end structure;

