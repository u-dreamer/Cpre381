-------------------------------------------------------------------------
-- Anna Huggins
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- adderSub_N.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file is the implementation of an adder-subtractor
--              
-- 09/09/2022
-------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity adderSub_N is
  generic(N : integer := 32);
  port(iCLK           : in std_logic;
       iA             : in std_logic_vector(N-1 downto 0);
       iB             : in std_logic_vector(N-1 downto 0);
       imm 	      : in std_logic_vector(N-1 downto 0);
       ALUSrc         : in std_logic;
       nAdd_Sub       : in std_logic;
       o_Sum          : out std_logic_vector(N-1 downto 0);
       o_C            : out std_logic);
end adderSub_N; 

architecture structure of adderSub_N is
  component onesComp
    port(i_A          : in std_logic_vector(N-1 downto 0);
         o_F          : out std_logic_vector(N-1 downto 0));

  end component;
  
  component mux2t1_N
    port(i_S                    : in std_logic;
         D0                     : in std_logic_vector(N-1 downto 0);
         D1                     : in std_logic_vector(N-1 downto 0);
         F_OUT                  : out std_logic_vector(N-1 downto 0));
  end component;

  component adder_N
    generic(N : integer := 32);
    port(iCLK    : in std_logic;
         i_C     : in std_logic;
         i_A     : in std_logic_vector(N-1 downto 0);
         i_B     : in std_logic_vector(N-1 downto 0);
         o_S     : out std_logic_vector(N-1 downto 0);
         o_C     : out std_logic);
  end component;

--- SIGNALS ---------------------------------------------------------------
signal select_B   : std_logic_vector(N-1 downto 0);
signal inv_B      : std_logic_vector(N-1 downto 0);
signal s_B        : std_logic_vector(N-1 downto 0);
---------------------------------------------------------------------------
   
begin

---------------------------------------------------------------------------
-- Level 0: Select which source we use for iB
---------------------------------------------------------------------------
 mux_selectB : mux2t1_N
  port MAP(i_S     => ALUSrc,
           D0      => iB,
           D1      => imm,
           F_OUT   => select_B);

---------------------------------------------------------------------------
-- Level 1: Invert B data
---------------------------------------------------------------------------
  inv_select: onesComp
    port MAP(i_A   =>  select_B,
             o_F   =>  inv_B);

---------------------------------------------------------------------------
-- Level 2: N-Bit 2:1 MUX
---------------------------------------------------------------------------    
  mux_iB: mux2t1_N
    port MAP(i_S   =>  nAdd_Sub,
             D0  =>  select_B,
             D1  =>  inv_B,            
             F_OUT   =>  s_B);


---------------------------------------------------------------------------
-- Level 3: Ripple-Carry Adder
---------------------------------------------------------------------------             
  adder_0: adder_N
      port MAP(iCLK =>  iCLK,
               i_C  =>  nAdd_Sub,
               i_A  =>  iA,
               i_B  =>  s_B,
               o_S  =>  o_Sum,
               o_C  =>  o_C);
end structure;


