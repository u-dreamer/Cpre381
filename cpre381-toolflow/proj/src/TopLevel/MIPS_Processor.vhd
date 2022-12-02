-------------------------------------------------------------------------
-- Henry Duwe
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- MIPS_Processor.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a skeleton of a MIPS_Processor  
-- implementation.

-- 01/29/2019 by H3::Design created.
-------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;

library work;
use work.MIPS_types.all;

entity MIPS_Processor is
  generic(N : integer := DATA_WIDTH;
	  C : integer := 22;
	  F : integer := 5);
	
  port(iCLK            : in std_logic;
       iRST            : in std_logic;
       iInstLd         : in std_logic;                        -- Determines if we load instr
       iInstAddr       : in std_logic_vector(N-1 downto 0);   -- Address of instr in iMem
       iInstExt        : in std_logic_vector(N-1 downto 0);   -- Data at instr addr.
       oALUOut         : out std_logic_vector(N-1 downto 0)); 
-- TODO: Hook this up to the output of the ALU. It is important for synthesis that you have 
-- this output that can effectively be impacted by all other components so they are not optimized away.

end  MIPS_Processor;

architecture structure of MIPS_Processor is

  -- Required data memory signals
  signal s_DMemWr       : std_logic; -- TODO: use this signal as the final active high data memory write enable signal
  signal s_DMemAddr     : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory address input
  signal s_DMemData     : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory data input
  signal s_DMemOut      : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the data memory output
 
  -- Required register file signals 
  signal s_RegWr        : std_logic; -- TODO: use this signal as the final active high write enable input to the register file
  signal s_RegWrAddr    : std_logic_vector(4 downto 0); -- TODO: use this signal as the final destination register address input
  signal s_RegWrData    : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory data input

  -- Required instruction memory signals
  signal s_IMemAddr     : std_logic_vector(N-1 downto 0); -- Do not assign this signal, assign to s_NextInstAddr instead
  signal s_NextInstAddr : std_logic_vector(N-1 downto 0); -- TODO: use this signal as your intended final instruction memory address input.
  signal s_Inst         : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the instruction signal 

  -- Required halt signal -- for simulation
  signal s_Halt         : std_logic;  -- TODO: this signal indicates to the simulation that intended program execution has completed. (Opcode: 01 0100)

  -- Required overflow signal -- for overflow exception detection
  signal s_Ovfl         : std_logic;  -- TODO: this signal indicates an overflow exception would have been initiated

  component mem is
    generic(ADDR_WIDTH : integer;
            DATA_WIDTH : integer);
    port(
          clk          : in std_logic;
          addr         : in std_logic_vector((ADDR_WIDTH-1) downto 0);
          data         : in std_logic_vector((DATA_WIDTH-1) downto 0);
          we           : in std_logic := '1';
          q            : out std_logic_vector((DATA_WIDTH -1) downto 0));
    end component;

  -- TODO: Add any additional signals or components we need below.

-- Component Declaration ------------------------------------------------

-- PC
--component PC is
--  generic(N : integer := 32);
--  port(i_CLK        : in std_logic;
--       i_RST        : in std_logic;
--       i_WE         : in std_logic;
--      i_D          : in  std_logic_vector(N-1 downto 0);
--      o_Q   	    : out std_logic_vector(N-1 downto 0));
--end component;

-- Fetch Unit
component fetchUnit is
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
end component;

-- Register File
component MIPS_Reg_File1 is
  generic(N : integer := 32;
          X : integer := 5);
  port (i_CLK	  : in std_logic;
	i_RST     : in std_logic;
	WE        : in std_logic;
	i_D       : in std_logic_vector(N-1 downto 0);
        rd 	  : in std_logic_vector(X-1 downto 0);
	rs 	  : in std_logic_vector(X-1 downto 0);
  	rt        : in std_logic_vector(X-1 downto 0);
	rs_val    : out std_logic_vector(N-1 downto 0);
	rt_val    : out std_logic_vector(N-1 downto 0));	
end component;

-- Control Unit
component controlUnit is
  generic(N : integer := 32;
          C : integer := 22;
	  F : integer := 6);
  port ( instr	      : in std_logic_vector(N-1 downto 0);
         controlOut   : out std_logic_vector(C-1 downto 0));
end component;

-- Sign Extender
component extender is
  generic(N : integer := 32;
          W : integer := 16);
  port ( i_imm   : in std_logic_vector(W-1 downto 0);
         ctrl    : in std_logic;
         F_OUT   : out std_logic_vector(N-1 downto 0));
end component;

-- Upgraded ALU
component upgradedALU is
  generic(N : integer := 32;
  	  S : integer := 10);
  port(CLK	  : in std_logic;
       ALUCtrl	  : in std_logic_vector(S-1 downto 0);
       i_A	  : in std_logic_vector(N-1 downto 0);
       i_B 	  : in std_logic_vector(N-1 downto 0);
       o_Result	  : out std_logic_vector(N-1 downto 0);
       o_Carry    : out std_logic;
       o_Overflow : out std_logic;
       o_Zero     : out std_logic);
  end component;

-- 32-Bit 2-to-1 Mux
component mux2t1_N is
  generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
  port(i_S          : in std_logic;
       D0           : in std_logic_vector(N-1 downto 0);
       D1           : in std_logic_vector(N-1 downto 0);
       F_OUT        : out std_logic_vector(N-1 downto 0));
end component;

-- 6-Bit 2-to-1 Mux
component mux2t1_6 is
  generic(N : integer := 5); -- Generic of type integer for input/output data width. Default value is 32.
  port(i_S          : in std_logic;
       D0           : in std_logic_vector(N-1 downto 0);
       D1           : in std_logic_vector(N-1 downto 0);
       F_OUT        : out std_logic_vector(N-1 downto 0));
end component;

-- 32-Bit AND Gate
component andg_N is
  port(i_A 	    : in std_logic_vector(N-1 downto 0);
       i_B	    : in std_logic_vector(N-1 downto 0);
       o_F	    : out std_logic_vector(N-1 downto 0));
end component;

--- SIGNALS ---------------------------------------------------------------
-- Register Signals
signal s_rs         : std_logic_vector(F-1 downto 0);
signal s_rt 	    : std_logic_vector(F-1 downto 0);
signal s_rd         : std_logic_vector(F-1 downto 0);

signal s_rsVal      : std_logic_vector(N-1 downto 0);
signal s_rtVal      : std_logic_vector(N-1 downto 0);


signal s_control    : std_logic_vector(C-1 downto 0); 

signal s_regDst     : std_logic_vector(F-1 downto 0);

-- Fetch Unit Signals
signal s_immExt     : std_logic_vector(N-1 downto 0);

signal s_srcB       : std_logic_vector(N-1 downto 0);
signal s_pcPlusFour : std_logic_vector(N-1 downto 0);
signal s_wrData     : std_logic_vector(N-1 downto 0); -- Intermediate signal to determine RegWrData

-- ALU Signals
signal s_Carry      : std_logic;
signal s_Zero       : std_logic;
--------------------------------------------------------------------------

begin

  -- TODO: This is required to be your final input to your instruction memory. This provides 
  -- a feasible method to externally load the memory module which means that the synthesis 
  -- tool must assume it knows nothing about the values stored in the instruction memory. 
  -- If this is not included, much, if not all of the design is optimized out because the 
  -- synthesis tool will believe the memory to be all zeros.
  with iInstLd select
    s_IMemAddr <= s_NextInstAddr when '0',
      iInstAddr when others;


  IMem: mem
    generic map(ADDR_WIDTH => ADDR_WIDTH,
                DATA_WIDTH => N)
    port map(clk  => iCLK,
             addr => s_IMemAddr(11 downto 2),
             data => iInstExt,
             we   => iInstLd,
             q    => s_Inst);
  
  DMem: mem
    generic map(ADDR_WIDTH => ADDR_WIDTH,
                DATA_WIDTH => N)
    port map(clk  => iCLK,
             addr => s_DMemAddr(11 downto 2),
             data => s_DMemData,
             we   => s_DMemWr,
             q    => s_DMemOut);

  -- TODO: Ensure that s_Halt is connected to an output control signal produced from decoding
  --       the Halt instruction (Opcode: 01 0100)
  -- TODO: Ensure that s_Ovfl is connected to the overflow output of your ALU

  -- TODO: Implement the rest of your processor below this comment! 


---------------------------------------------------------------------------
-- Level 0: PC
---------------------------------------------------------------------------
--ProcessCounter: PC
--port MAP(i_CLK           => iCLK,
--         i_RST           => iRST,
--         i_WE            => iInstLd,
 --        i_D             => iInstAddr,
 --        o_Q   	         => iInstData);

---------------------------------------------------------------------------
-- Level 1: Control Unit / Fetch Unit
-- Control Bits Explained:
--   X     X      X    X    X     X      X	 X       X       X	 X	 X   
--  21    20     19   18   17    16     15      14      13      12	11	10    
-- Halt SignExt Jump Jal JReg RegDst RegWrite Branch MemToReg MemRead MemWrite ALUSrc 
---------------------------------------------------------------------------
controlUnit1: controlUnit
  port MAP(instr          => s_Inst,
	   controlOut     => s_control);

s_rs <= s_Inst(25 downto 21);
s_rt <= s_Inst(20 downto 16);
s_rd <= s_Inst(15 downto 11);

-- TODO: use this signal as the final active high write enable input to the register file
s_RegWr  <= s_control(15); -- Assign as value from control unit output

-- Assign Memory Control Signals
s_DMemWr <= s_control(11);
 

---------------------------------------------------------------------------
-- Level 2: Mux0 (RegDst) / Mux1 (JAL) / Mux2 (WrData) / Fetch Unit
---------------------------------------------------------------------------
mux2t1_6_0: mux2t1_6 
  port MAP(i_S            => s_control(16),  -- RegDst Bit
           D0             => s_rt,
           D1             => s_rd,
           F_OUT          => s_RegDst);

mux2t1_6_1: mux2t1_6
  port MAP(i_S            => s_control(18), -- JAL Bit
           D0             => s_RegDst,
           D1             => "11111",         -- Load in Jal reg addr.
           F_OUT          => s_RegWrAddr);  -- Writes final WrAddr to Reg

mux2t1_2: mux2t1_N
  port MAP(i_S            => s_control(18), -- JAL Bit
           D0             => s_pcPlusFour,
           D1             => s_wrData,
           F_OUT          => s_RegWrData);  -- Select write data

fetchUnit0: fetchUnit
  port MAP(iCLK          => iCLK,
	   jAddr         => s_rsVal(25 downto 0),
           pcIn          => s_NextInstAddr, -- *Fixed?
           branchAddr    => s_immExt,
           branchEnable  => s_control(14), -- BrEn control
           jumpDisable   => s_control(19), -- Jump control
           jrAddr	 => s_rsVal,
           jrEn          => s_control(17), -- Jr control
           pcOut         => s_NextInstAddr,
           pcPlusFour    => s_pcPlusFour);


---------------------------------------------------------------------------
-- Level 3: MIPS Register File / Sign Extender
---------------------------------------------------------------------------
RegisterFile: MIPS_Reg_File1 
  port MAP(i_CLK	 => iCLK,
	   i_RST         => iRST,
	   WE            => s_RegWr,
	   i_D           => s_RegWrData,
           rd 	         => s_rd,
	   rs 	         => s_rs,
  	   rt            => s_rt,
	   rs_val        => s_rsVal,
	   rt_val        => s_rtVal);

SignExtender: extender
  port MAP( i_imm        => s_Inst(15 downto 0),  -- Get imm bits from Inst
            ctrl         => s_control(20),
            F_OUT        => s_immExt);

---------------------------------------------------------------------------
-- Level 4: Mux3 (ALU Src B)
---------------------------------------------------------------------------
mux2t1_3: mux2t1_N
  port MAP(i_S            => s_control(10), -- ALUSrc Bit
           D0             => s_rtVal,
           D1             => s_immExt,
           F_OUT          => s_srcB);  -- Select write data

s_RegWrData <= s_rtVal;

---------------------------------------------------------------------------
-- Level 5: ALU
---------------------------------------------------------------------------
ALU: upgradedALU
  port MAP(CLK	          => iCLK,
           ALUCtrl	  => s_control(9 downto 0),
           i_A	          => s_rsVal,
           i_B 	          => s_srcB,
           o_Result	  => oALUOut,  -- Results -> DMem
           o_Carry        => s_Carry,
           o_Overflow     => s_Ovfl,      -- Signal was provided.
           o_Zero         => s_Zero);

-- Write to o_Result to s_DMemAddr, too
s_DMemAddr <= oALUOut;

---------------------------------------------------------------------------
-- Level 5: Mux4 (MemToReg)
---------------------------------------------------------------------------
mux2t1_4: mux2t1_N
  port MAP(i_S            => s_control(13), -- MemToReg
           D0             => s_DMemAddr,    -- ALU Result
           D1             => s_DMemOut,     -- DMem Data
           F_OUT          => s_wrData);     -- Data to Write (to Reg)

end structure;

