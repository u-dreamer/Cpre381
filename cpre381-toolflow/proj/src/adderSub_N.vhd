-------------------------------------------------------------------------
-- L8Sk8rs
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- adderSub_N.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file is the implementation of an N-bit 
--              adder-subtractor.
-------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity adderSub_N is
  generic(N : integer := 32);
  port(iCLK           : in std_logic;
       iA             : in std_logic_vector(N-1 downto 0);
       iB             : in std_logic_vector(N-1 downto 0);
       nAdd_Sub       : in std_logic;
       Ov             : in std_logic;
       o_Sum          : out std_logic_vector(N-1 downto 0);
       o_C            : out std_logic;
       o_Ov	      : out std_logic);
  end adderSub_N; 

architecture structure of adderSub_N is
  component onesComp
    port(i_A          : in std_logic_vector(N-1 downto 0);
         o_F          : out std_logic_vector(N-1 downto 0));

  end component;
  
  component mux2t1_N
    port(i_S          : in std_logic;
         D0           : in std_logic_vector(N-1 downto 0);
         D1           : in std_logic_vector(N-1 downto 0);
         F_OUT        : out std_logic_vector(N-1 downto 0));
  end component;

  component mux2t1
    port(i_S          : in std_logic;
         i_D0         : in std_logic;
         i_D1         : in std_logic;
         o_O          : out std_logic);
  end component;

  component adder_N
    generic(N : integer := 32);
    port(iCLK         : in std_logic;
         i_C          : in std_logic;
         i_A          : in std_logic_vector(N-1 downto 0);
         i_B          : in std_logic_vector(N-1 downto 0);
         o_S          : out std_logic_vector(N-1 downto 0);
         o_C          : out std_logic);
  end component;

  component andg2
    port(i_A          : in std_logic;
         i_B          : in std_logic;
         o_F          : out std_logic);
    end component;

--- SIGNALS ---------------------------------------------------------------
signal s_invB         : std_logic_vector(N-1 downto 0);
signal s_B            : std_logic_vector(N-1 downto 0);
signal s_Sum	      : std_logic_vector(N-1 downto 0);
signal s_C	      : std_logic;
signal s_Ov	      : std_logic;
---------------------------------------------------------------------------

begin

---------------------------------------------------------------------------
-- Level 0: Invert B data
---------------------------------------------------------------------------
  inv_select: onesComp
    port MAP(i_A   =>  iB,
             o_F   =>  s_invB);

---------------------------------------------------------------------------
-- Level 1: N-bit 2:1 MUX (choose btw iB and ~iB)
---------------------------------------------------------------------------    
  mux_iB: mux2t1_N
    port MAP(i_S   =>  nAdd_Sub,
             D0    =>  iB,
             D1    =>  s_invB,            
             F_OUT =>  s_B);

---------------------------------------------------------------------------
-- Level 2: RCA (do the adding or sub-ing)
---------------------------------------------------------------------------             
  adder_0: adder_N
      port MAP(iCLK =>  iCLK,
               i_C  =>  nAdd_Sub,
               i_A  =>  iA,
               i_B  =>  s_B,
               o_S  =>  s_Sum,
               o_C  =>  s_C);

  o_Sum <= s_Sum;
  o_C   <= s_C;

---------------------------------------------------------------------------
-- Level 3: N-bit AND gate (has overflow?)
---------------------------------------------------------------------------
  and_Ov: andg2
      port MAP(i_A  =>  s_Sum(N-1), -- Only need most significant bit
               i_B  =>  s_C,
               o_F  =>  s_Ov);

---------------------------------------------------------------------------
-- Level 4: 2:1 MUX (is signed?)
---------------------------------------------------------------------------
  mux_isSigned: mux2t1
    port MAP(i_S     =>  Ov,
             i_D0    =>  '0',
             i_D1    =>  s_Ov,
             o_O     =>  o_Ov);

end structure;