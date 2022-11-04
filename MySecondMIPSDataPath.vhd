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

entity MySecondMIPSDataPath is
      generic(N : integer := 32;
              X : integer := 5;
	      W : integer := 16);
      port(i_CLK        : in std_logic;
           i_RST        : in std_logic;
           WE           : in std_logic;
           nAdd_Sub     : in std_logic;
           ALUSrc       : in std_logic;
           ctrl         : in std_logic;
           WE_mem       : in std_logic;
           LE           : in std_logic;
           rd 	        : in std_logic_vector(X-1 downto 0);
	   rs 	        : in std_logic_vector(X-1 downto 0);
  	   rt           : in std_logic_vector(X-1 downto 0);
           imm          : in std_logic_vector(W-1 downto 0);
           o_Sum	: out std_logic_vector(N-1 downto 0);
           o_C          : out std_logic);
end MySecondMIPSDataPath;

architecture structure of MySecondMIPSDataPath is
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
         imm 	        : in std_logic_vector(N-1 downto 0);
         ALUSrc         : in std_logic;
         nAdd_Sub       : in std_logic;
         o_Sum          : out std_logic_vector(N-1 downto 0);
         o_C            : out std_logic);
  end component;

  component extender is 
    port ( i_imm   : in std_logic_vector(W-1 downto 0);
           ctrl : in std_logic;
           F_OUT   : out std_logic_vector(N-1 downto 0));
  end component;

  component mem is
    generic( DATA_WIDTH : natural := 32;
	     ADDR_WIDTH : natural := 10);
    port( clk		: in std_logic;
	  addr	        : in std_logic_vector((ADDR_WIDTH-1) downto 0);
	  data	        : in std_logic_vector((DATA_WIDTH-1) downto 0);
	  we		: in std_logic := '0';
          q		: out std_logic_vector((DATA_WIDTH -1) downto 0));
  end component;

  component mux2t1_N is
    port( i_S            : in std_logic;
          D0             : in std_logic_vector(N-1 downto 0);
          D1             : in std_logic_vector(N-1 downto 0);
          F_OUT          : out std_logic_vector(N-1 downto 0));
  end component;

--- SIGNALS ---------------------------------------------------------------
signal s_rs    : std_logic_vector(N-1 downto 0);
signal s_rt    : std_logic_vector(N-1 downto 0);
signal ext_imm : std_logic_vector(N-1 downto 0);
signal q_val   : std_logic_vector(N-1 downto 0);
signal ld_val  : std_logic_vector(N-1 downto 0);
---------------------------------------------------------------------------

begin

---------------------------------------------------------------------------
-- Level 0: MIPS Register File + Extender! :D
---------------------------------------------------------------------------
g_MIPS_Reg_File: MIPS_Reg_File1
   port MAP(i_CLK     => i_CLK,
	    i_RST     => i_RST,
	    WE        => WE,
	    i_D       => ld_val,
            rd 	      => rd,
	    rs 	      => rs,
  	    rt        => rt,
	    rs_val    => s_rs,
	    rt_val    => s_rt);

g_Extender: extender
  port MAP( i_imm     => imm,
            ctrl      => ctrl,
            F_OUT     => ext_imm);

---------------------------------------------------------------------------
-- Level 1: AdderSub + Memory
---------------------------------------------------------------------------
 g_AdderSub: AdderSub_N
   port MAP(iCLK      => i_CLK,
            iA        => s_rs,
            iB        => s_rt,
            imm       => ext_imm,
            ALUSrc    => ALUSrc,
            nAdd_Sub  => nAdd_Sub,
            o_Sum     => o_Sum,
            o_C       => o_C);

 g_Memory: mem
  port MAP( clk       => i_CLK,
            addr      => o_Sum(11 downto 2),
            data      => s_rt,
            we        => WE_mem,
            q         => q_val);

---------------------------------------------------------------------------
-- Level 2: Mux -> Decide what to load (into rd)
---------------------------------------------------------------------------
 g_Mux: mux2t1_N
   port MAP( i_S      => LE,
             D0       => o_Sum,
             D1       => q_val, 
             F_OUT    => ld_val);

 end structure;

