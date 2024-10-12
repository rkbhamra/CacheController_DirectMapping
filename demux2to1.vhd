----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:25:53 10/12/2024 
-- Design Name: 
-- Module Name:    demux2to1 - Behavioral 
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

entity demux2to1 is
    Port ( din : in  STD_LOGIC_VECTOR (7 downto 0);
           dout1 : out  STD_LOGIC_VECTOR (7 downto 0);
           dout2 : out  STD_LOGIC_VECTOR (7 downto 0);
           sw : in  STD_LOGIC);
end demux2to1;

architecture Behavioral of demux2to1 is

begin
	process(sw)
	begin
		case sw is
			when '0' => dout1 <= din;
			when '1' => dout2 <= din;
			when others => dout1 <= "00000000";
		end case;
	end process;

end Behavioral;

