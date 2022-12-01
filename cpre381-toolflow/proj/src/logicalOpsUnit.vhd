-------------------------------------------------------------------------
-- Anna Huggins
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- logicalOpsUnit.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of a ones complementor.
-- Inverts each individual bit of an n-bit input.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity logicalOpsUnit is
  generic(N : integer := 32;
  	  S : integer := 3);
  port(outputSel  : in std_logic_vector(S-1 downto 0);
       i_A	  : in std_logic_vector(N-1 downto 0);
       i_B 	  : in std_logic_vector(N-1 downto 0);
       o_F	  : out std_logic_vector(N-1 downto 0));
  end logicalOpsUnit;

architecture mixed of logicalOpsUnit is


-- Component Declaration ------------------------------------------------
-- NOT Gate
component onesComp is
  generic(N : integer := 32);
  port(i_A 	  : in std_logic_vector(N-1 downto 0);
       o_F	  : out std_logic_vector(N-1 downto 0));
  end component;

-- XOR Gate
component xorg_N is
  generic(N : integer := 32);
  port(i_A	   : in std_logic_vector(N-1 downto 0);
       i_B         : in std_logic_vector(N-1 downto 0);
       o_F         : out std_logic_vector(N-1 downto 0));
  end component;

-- OR Gate
component org_N is
  generic(N : integer := 32);
  port(i_A	   : in std_logic_vector(N-1 downto 0);
       i_B         : in std_logic_vector(N-1 downto 0);
       o_F         : out std_logic_vector(N-1 downto 0));
  end component;

-- NOR Gate
component norg_N
  generic(N : integer := 32);
  port(i_A 	  : in std_logic_vector(N-1 downto 0);
       i_B	  : in std_logic_vector(N-1 downto 0);
       o_F	  : out std_logic_vector(N-1 downto 0));
  end component;

-- AND Gate
component andg_N
  generic(N : integer := 32);
  port(i_A 	  : in std_logic_vector(N-1 downto 0);
       i_B	  : in std_logic_vector(N-1 downto 0);
       o_F	  : out std_logic_vector(N-1 downto 0));
  end component;

-- SLT 
component slt is
  generic(N : integer := 32);
  port(i_A	   : in std_logic_vector(N-1 downto 0);
       i_B         : in std_logic_vector(N-1 downto 0);
       o_F         : out std_logic_vector(N-1 downto 0));
  end component;

-- repl.qb
component replqb is
  generic(N : integer := 32;
	  B : integer := 8);
   port(i_B	  : in std_logic_vector(N-1 downto 0);
        o_F	  : out std_logic_vector(N-1 downto 0));
  end component;

-- LUI
component LUI is
  generic(N : integer := 32);
  port(i_B         : in std_logic_vector(N-1 downto 0);
       o_F         : out std_logic_vector(N-1 downto 0));
  end component;

--- SIGNALS ---------------------------------------------------------------
signal s_NOT   : std_logic_vector(N-1 downto 0);
signal s_XOR   : std_logic_vector(N-1 downto 0);
signal s_OR    : std_logic_vector(N-1 downto 0);   
signal s_NOR   : std_logic_vector(N-1 downto 0);  
signal s_AND   : std_logic_vector(N-1 downto 0);  
signal s_SLT   : std_logic_vector(N-1 downto 0);  
signal s_replqb: std_logic_vector(N-1 downto 0); 
signal s_LUI   : std_logic_vector(N-1 downto 0); 
---------------------------------------------------------------------------

begin

---------------------------------------------------------------------------
-- Level 0: Perform Logical Operations
---------------------------------------------------------------------------
-- NOT Gate
invg: onesComp
  port MAP(i_A 	  => i_A,
           o_F	  => s_NOT);

-- XOR Gate
xorg: xorg_N
  port MAP(i_A 	  => i_A,
           i_B	  => i_B,
           o_F	  => s_XOR);

-- OR Gate
org: org_N
  port MAP(i_A 	  => i_A,
           i_B	  => i_B,
           o_F	  => s_OR);

-- NOR Gate
norg: norg_N
  port MAP(i_A 	  => i_A,
           i_B	  => i_B,
           o_F	  => s_NOR);

-- AND Gate
andg: andg_N
  port MAP(i_A 	  => i_A,
           i_B	  => i_B,
           o_F	  => s_AND);

-- SLT
slt1: slt
  port MAP(i_A 	  => i_A,
           i_B	  => i_B,
           o_F	  => s_SLT);

-- repl.qb
replqb1: replqb
   port MAP(i_B	  => i_B,
            o_F	  => s_replqb);

-- LUI
LUI1: LUI
  port MAP(i_B    => i_B,
           o_F    => s_LUI);
---------------------------------------------------------------------------
-- Level 1: Select Logical Operation to be Output
---------------------------------------------------------------------------

 with outputSel(2 downto 0) select o_F <= 
   s_NOT    when "000", 
   s_XOR    when "001",
   s_OR     when "010",
   s_NOR    when "011",
   s_AND    when "100",
   s_SLT    when "101",
   s_replqb when "110",
   s_LUI    when "111",
   "1111111111111" when others;


end mixed;



  