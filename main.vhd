----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:18:01 10/12/2024 
-- Design Name: 
-- Module Name:    main - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity main is
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC);
end main;

architecture Behavioral of main is
	COMPONENT CPU_gen 
	Port ( 
		clk 		: in  STD_LOGIC;
      rst 		: in  STD_LOGIC;
      trig 		: in  STD_LOGIC;
		-- Interface to the Cache Controller.
      Address 	: out  STD_LOGIC_VECTOR (15 downto 0);
      wr_rd 	: out  STD_LOGIC;
      cs 		: out  STD_LOGIC;
      DOut 		: out  STD_LOGIC_VECTOR (7 downto 0)
	);
	END COMPONENT;
	
	COMPONENT controller 
    Port ( clk : in  STD_LOGIC;
			  rst : in STD_LOGIC;
           cacheAddr : in  STD_LOGIC_VECTOR (15 downto 0);
           wr_rd_c : in  STD_LOGIC;
           cStrb : in  STD_LOGIC;
			  cpu_data_out : in STD_LOGIC_VECTOR (7 downto 0);
			  mem_dout : in STD_LOGIC_VECTOR (7 downto 0);
			  mem_din : out STD_LOGIC_VECTOR (7 downto 0);
           RDY : out  STD_LOGIC;
           memAddr : out  STD_LOGIC_VECTOR (15 downto 0);
           wr_rd_m : out  STD_LOGIC;
           memStrb : out  STD_LOGIC);
--           wen : out  STD_LOGIC);
	END COMPONENT;
	
	COMPONENT SDRAM_controller is
    Port ( clk : in  STD_LOGIC;
			  MemAddr_SDRAM : in  STD_LOGIC_VECTOR (15 downto 0);
           wr_rd_SDRAM : in  STD_LOGIC;
           MemStrb_SDRAM : in  STD_LOGIC;
           Din_SDRAM : in  STD_LOGIC_VECTOR (7 downto 0);
           Dout_SDRAM : out  STD_LOGIC_VECTOR (7 downto 0));
	END COMPONENT;
	
	COMPONENT ILA
	  PORT (
		 CONTROL : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0);
		 CLK : IN STD_LOGIC;
		 DATA : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
		 TRIG0 : IN STD_LOGIC_VECTOR(7 DOWNTO 0));
	END COMPONENT;
	
	COMPONENT VIO PORT (
		 CONTROL : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0);
		 ASYNC_OUT : OUT STD_LOGIC_VECTOR(17 DOWNTO 0));
	END COMPONENT;
	
	COMPONENT ICON2
	  PORT (
		 CONTROL0 : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0);
		 CONTROL1 : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0));
	END COMPONENT;
	
	signal cpu_data_out_buf : STD_LOGIC_VECTOR(7 downto 0);
	signal mem_data_out_buf : STD_LOGIC_VECTOR(7 downto 0);
	--signal address_out_cpu : STD_LOGIC_VECTOR (15 downto 0);
	signal trig_buf : STD_LOGIC;
	signal cacheAddr_buf : STD_LOGIC_VECTOR (15 downto 0);
	signal wr_rd_c_buf : STD_LOGIC;
	signal cStrb_buf : STD_LOGIC;
	signal MemAddr_SDRAM_buf : STD_LOGIC_VECTOR(15 downto 0);
	signal wr_rd_SDRAM_buf : STD_LOGIC;
	signal MemStrb_SDRAM_buf : STD_LOGIC;
	signal mem_din_buf : STD_LOGIC_VECTOR (7 downto 0);
	signal rst_buf : STD_LOGIC := '0';
	signal control0 : STD_LOGIC_VECTOR (35 DOWNTO 0);
	signal control1 : STD_LOGIC_VECTOR (35 DOWNTO 0);
	signal ila_data : STD_LOGIC_VECTOR (63 DOWNTO 0);
	signal trig0 : STD_LOGIC_VECTOR (7 DOWNTO 0);
	signal vio_out : STD_LOGIC_VECTOR (17 DOWNTO 0);

begin
	cpu : CPU_gen 	Port Map( 
		clk => clk,
      rst => rst_buf,	
      trig =>	trig_buf,
		-- Interface to the Cache Controller.
      Address 	=> cacheAddr_buf,
      wr_rd => wr_rd_c_buf,
      cs => cStrb_buf,
      DOut => cpu_data_out_buf);
	
	cache : controller Port Map( 
		clk => clk,
		cacheAddr => cacheAddr_buf,
		wr_rd_c => wr_rd_c_buf,
		cStrb => cStrb_buf,
		mem_din => mem_din_buf,
		RDY => trig_buf,
		mem_dout => mem_data_out_buf,
		cpu_data_out => cpu_data_out_buf,
		memAddr => MemAddr_SDRAM_buf,
		wr_rd_m => wr_rd_SDRAM_buf,
		memStrb => MemStrb_SDRAM_buf,
		rst => rst_buf
		);
	
	mainMemory : SDRAM_controller Port Map( 
		clk  => clk,
		MemAddr_SDRAM =>  MemAddr_SDRAM_buf,
		wr_rd_SDRAM  => wr_rd_SDRAM_buf,
		MemStrb_SDRAM => MemStrb_SDRAM_buf,
		Din_SDRAM => mem_din_buf,
		Dout_SDRAM => mem_data_out_buf);
		
	mapped : ILA	port map (
		 CONTROL => control0,
		 CLK => clk,
		 DATA => ila_data,
		 TRIG0 => trig0
	);
	
	input : VIO port map (
		 CONTROL => control1,
		 ASYNC_OUT => vio_out
	);
	
	connect : ICON2 port map (
		 CONTROL0 => control0,
		 CONTROL1 => control1
	);
	

	ila_data (7 downto 0) <= cpu_data_out_buf;
	ila_data (15 downto 8) <= mem_data_out_buf;
	ila_data (23 downto 16) <= mem_din_buf;
	ila_data (24) <= trig_buf;
	ila_data (40 downto 25) <= cacheAddr_buf;
	ila_data (41) <= wr_rd_c_buf;
	ila_data (42) <= cStrb_buf;
	ila_data (58 downto 43) <= MemAddr_SDRAM_buf;
	ila_data (59) <= wr_rd_SDRAM_buf;
	ila_data (60) <= MemStrb_SDRAM_buf;
	ila_data (61) <= wr_rd_SDRAM_buf;
	ila_data (62) <= rst_buf;
	

end Behavioral;
