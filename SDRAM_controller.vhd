----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:05:07 09/26/2024 
-- Design Name: 
-- Module Name:    SDRAM_controller - Behavioral 
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
-- use IEEE.NUMERIC_STD.ALL;
-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
-- library UNISIM;
-- use UNISIM.VComponents.all;

entity SDRAM_controller is
    Port ( clk : in  STD_LOGIC;
			  MemAddr_SDRAM : in  STD_LOGIC_VECTOR (15 downto 0);
           wr_rd_SDRAM : in  STD_LOGIC;
           MemStrb_SDRAM : in  STD_LOGIC;
           Din_SDRAM : in  STD_LOGIC_VECTOR (7 downto 0);
           Dout_SDRAM : out  STD_LOGIC_VECTOR (7 downto 0));
end SDRAM_controller;

architecture Behavioral of SDRAM_controller is

	-- COMPONENT DECLARATIONS
	COMPONENT SDRAM 
	PORT (
    clka : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
	END COMPONENT;

	-- signals for cache controller
	signal memStrb : STD_LOGIC;
	--signal memAddr : STD_LOGIC_VECTOR(11 downto 0);
	signal wr_rd_m : STD_LOGIC;
	--signal mem_din : STD_LOGIC(7 downto 0):
	--signal mem_dout : STD_LOGIC(7 downto 0):
	--signal mem_strb_buf : STD_LOGIC := '0';

begin
	mainMemory : SDRAM PORT MAP (
		 clka => clk,
		 wea => wr_rd_m,
		 addra => MemAddr_SDRAM,
		 dina => Din_SDRAM,
		 douta => Dout_SDRAM
	);
	
	process (clk)
	begin
		if MemStrb_SDRAM = "1" then
			if wr_rd_SDRAM = "0" then
				wr_rd_m <= "1";
			elsif wr_rd_SDRAM = "1" then
				wr_rd_m <= "0";
			end if;
		elsif MemStrb_SDRAM = "0" then
			wr_rd_m <= "0";
		end if;
	end process;
end Behavioral;

