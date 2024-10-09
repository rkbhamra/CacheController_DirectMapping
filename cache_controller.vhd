----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    08:52:02 09/26/2024 
-- Design Name: 
-- Module Name:    controller - Behavioral 
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
USE ieee.std_logic_unsigned.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity controller is
    Port ( clk : in  STD_LOGIC;
           cacheAddr : in  STD_LOGIC_VECTOR (15 downto 0);
           wr_rd_c : in  STD_LOGIC;
           cStrb : in  STD_LOGIC;
           RDY : out  STD_LOGIC;
           memAddr : out  STD_LOGIC_VECTOR (15 downto 0);
           wr_rd_m : out  STD_LOGIC;
           memStrb : out  STD_LOGIC;
           dbit : out  STD_LOGIC;
           vbit : out  STD_LOGIC;
           index_offset : out  STD_LOGIC_VECTOR (7 downto 0);
           wen : out  STD_LOGIC);
end controller;

architecture Behavioral of controller is
	-- define the address word register
	TYPE tag_word IS RECORD
	  tag  : STD_LOGIC_VECTOR(7 DOWNTO 0); 
	  vbit : STD_LOGIC; 
	  dbit : STD_LOGIC; 
	END RECORD;

	-- array to hold tag words for each cache block (8 blocks)
	signal tag_array : ARRAY(0 TO 7) of tag_word;

	------------------------SIGNALS-------------------------
	-- Signals to extract the tag, index, and offset from address
	signal tag    : STD_LOGIC_VECTOR(7 DOWNTO 0);
	signal index  : STD_LOGIC_VECTOR(2 DOWNTO 0); -- 3 bits for 8 blocks
	signal offset : STD_LOGIC_VECTOR(4 DOWNTO 0); -- Byte-level offset within a block

    signal cache_index_offset : STD_LOGIC_VECTOR(7 DOWNTO 0);
	signal cache_data_out : STD_LOGIC_VECTOR(7 DOWNTO 0);
    signal cache_data_in : STD_LOGIC_VECTOR(7 DOWNTO 0);
	signal cache_write_enable : STD_LOGIC_VECTOR(0 DOWNTO 0);
	
	signal memAddr : STD_LOGIC_VECTOR(15 downto 0);
	signal wr_rd_m : STD_LOGIC;

    signal cpu_data_in : STD_LOGIC_VECTOR(7 downto 0);
    signal cpu_data_out : STD_LOGIC_VECTOR(7 downto 0);

begin
	
	component wrapped_cacheMemory
		  Port map(
			clka => clk,
			wea => cache_write_enable,
			addra => addr(7 DOWNTO 0), -- Using lower 8 bits as address for cache
			dina => data_in,
			douta => cache_data_out
	end component;
	
	component SDRAM_controller is
    Port map( clk : in  STD_LOGIC;
			  MemAddr_SDRAM => memAddr;
           wr_rd_SDRAM => wr_rd_m;
           --MemStrb_SDRAM : in  STD_LOGIC;
           --Din_SDRAM : in  STD_LOGIC_VECTOR (7 downto 0);
           --Dout_SDRAM : out  STD_LOGIC_VECTOR (7 downto 0));
	end component SDRAM_controller;
	
   process (clk)
		begin
        if rising_edge(clk) and cStrb = "1" and RDY ="1" then
            -- extract tag, index, and offset
            tag <= cacheAddr(15 downto 8);
            index <= cacheAddr(7 downto 5);
            offset <= cacheAddr(4 downto 0);
				
				-- check if vbit is 0, then it is a miss
				if vbit = "0" then
					hit <= "0";		--it is a miss
					-- Block is invalid. 
					-- Fetch block from main memory, update tag, set vBit to 1, write to cache.
					wen <= "1";
					memAddr <= tag&index&"00000";	    --send block starting address to memory
					wr_rd_m <= "1"; 				    --read from SDRAM
					tag_array(index).tag <= tag;	    --set tag and vbit in the addr reg
					tag_array(index).vbit <= "1";
					--index_offset <= index&"00000";
					wen <= "0";						    --done writing to cache
					if wr_rd_c = "0" then			    --write
						index_offset <= index&offset;   
						vbit <= "0";
						wen <= "1";
						-- wait for one clock cycle
						wen <= "0";
						tag_array(index).dbit <= "1";
					else if wr_rd_c ="1" then
						index_offset <= index&offset;
						tag_array(index).vbit <= "0";
					end if;
                else if vbit = "1" then
                    if tag_array(index).tag = tag then
                        hit = "1";
                        if tag_array(index).dbit = "1" then
                            if wr_rd_c = "1" then
                                --Block is valid and dirty. Read directly from cache.
                                cache_index_offset <= index&offset;
                                cpu_data_in <= cache_data_out;
                            else if wr_rd_c = "0" then
                                --Block is valid and dirty. Write directly to cache, dBit remains 1 (dirty).
                                cache_index_offset <= index&offset;
                                cpu_data_out <= cache_data_in;
                                vbit <= "0";
                                cache_write_enable <= "1";
                                -- wait clock cycles
                                vbit <= "1";
                            end if;
                        else if tag_array(index).dbit = "0" then
                            if wr_rd_c = "1" then
                                --Block is valid and clean. Read directly from cache.
                                cache_index_offset <= index&offset;
                                cpu_data_in <= cache_data_out;
                            else if wr_rd_c = "0" then
                                --Block is valid and clean. Write directly to cache and set dBit to 1 (dirty).
                                cache_index_offset <= index&offset;
                                cpu_data_out <= cache_data_in;
                                vbit <= "0";
                                cache_write_enable <= "1";
                            end if;
                        end if;
                    else if tag_array(index).tag /= tag then
                        hit = "0";
                        if tag_array(index).dbit = "0" then
                            if wr_rd_c = "1" then
                                --Block is valid but clean. Fetch new block from main memory, update tag, and set vBit to 1.
                                wen <= "1";
                                memAddr <= tag&index&"00000";	    --send block starting address to memory
                                wr_rd_m <= "1"; 				    --read from SDRAM
                                tag_array(index).tag <= tag;	    --set tag and vbit in the addr reg
                                tag_array(index).vbit <= "1";
                                index_offset <= index&offset;
                                wen <= "0";						    --done writing to cache
                            else if wr_rd_c = "0" then
                                --Block is valid but clean. Fetch new block from main memory, update tag, and set vBit to 1. Write to cache. dBit set to 1.
                                wen <= "1";
                                memAddr <= tag&index&"00000";	    --send block starting address to memory
                                wr_rd_m <= "1"; 				    --read from SDRAM
                                tag_array(index).tag <= tag;	    --set tag and vbit in the addr reg
                                tag_array(index).vbit <= "1";
                                index_offset <= index&offset;
                                wen <= "0";						    --done writing to cache
                                tag_array(index).dbit <= "1";
                            end if;
                        else if tag_array(index).dbit = "1" then
                            if wr_rd_c = "1" then
                                --Block is valid and dirty. Write back to memory, fetch new block from main memory, update tag, and set vBit to 1.
                                wen <= "1";
                                memAddr <= tag&index&"00000";	    --send block starting address to memory
                                wr_rd_m <= "0"; 				    --write to SDRAM
                                tag_array(index).tag <= tag;	    --set tag and vbit in the addr reg
                                tag_array(index).vbit <= "1";
                                index_offset <= index&offset;
                                wen <= "0";						    --done writing to cache
                            else if wr_rd_c = "0" then
                                --Block is valid and dirty. Write back to memory, fetch new block from main memory, update tag, set vBit to 1. Write to cache, set dBit to 1.
                                wen <= "1";
                                memAddr <= tag&index&"00000";	    --send block starting address to memory
                                wr_rd_m <= "0"; 				    --write to SDRAM
                                tag_array(index).tag <= tag;	    --set tag and vbit in the addr reg
                                tag_array(index).vbit <= "1";
                                index_offset <= index&offset;
                                wen <= "0";						    --done writing to cache
                                tag_array(index).dbit <= "1";
                    end if;
				end if;
        end if;
    end process;
end Behavioral;

