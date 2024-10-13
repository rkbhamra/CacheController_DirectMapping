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
use IEEE.NUMERIC_STD.ALL;  -- Use numeric_std for integer conversion

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity controller is
    Port ( clk : in  STD_LOGIC;
			  rst : in STD_LOGIC;
           cacheAddr : in  STD_LOGIC_VECTOR (15 downto 0);
           wr_rd_c : in  STD_LOGIC;
           cStrb : in  STD_LOGIC;
			  cpu_data_out :in STD_LOGIC_VECTOR(7 DOWNTO 0);
			  mem_dout :in STD_LOGIC_VECTOR(7 DOWNTO 0);
			  mem_din : out STD_LOGIC_VECTOR(7 DOWNTO 0);
           RDY : out  STD_LOGIC := '0';
           memAddr : out  STD_LOGIC_VECTOR (15 downto 0);
           wr_rd_m : out  STD_LOGIC;
           memStrb : out  STD_LOGIC;
           --dbit : out  STD_LOGIC;
           --vbit : out  STD_LOGIC;
           --index_offset : out  STD_LOGIC_VECTOR (7 downto 0);
           wen : out  STD_LOGIC);
end controller;

architecture Behavioral of controller is

	COMPONENT cacheMemory
	PORT (
    clka : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
	END COMPONENT;
	
	COMPONENT mux2to1 
   PORT ( din1 : in  STD_LOGIC_VECTOR (7 downto 0);
           din2 : in  STD_LOGIC_VECTOR (7 downto 0);
           dout : out  STD_LOGIC_VECTOR (7 downto 0);
           sw : in  STD_LOGIC);
	END COMPONENT;
	
	COMPONENT demux2to1 is
    Port ( din : in  STD_LOGIC_VECTOR (7 downto 0);
           dout1 : out  STD_LOGIC_VECTOR (7 downto 0);
           dout2 : out  STD_LOGIC_VECTOR (7 downto 0);
           sw : in  STD_LOGIC);
	END COMPONENT;
	
	-- define the address word register
	TYPE tag_word IS RECORD
	  tag  : STD_LOGIC_VECTOR(7 DOWNTO 0); 
	  vbit : STD_LOGIC; 
	  dbit : STD_LOGIC; 
	END RECORD;

	-- array to hold tag words for each cache block (8 blocks)
	type tag_array_type is array (0 to 7) of tag_word;
	signal tag_array : tag_array_type;

	------------------------SIGNALS-------------------------
	--	signal hit : STD_LOGIC;
	signal dbit : STD_LOGIC;
   signal vbit : STD_LOGIC;
	
	-- Signals to extract the tag, index, and offset from address
	signal tag    : STD_LOGIC_VECTOR(7 DOWNTO 0);
	signal index  : STD_LOGIC_VECTOR(2 DOWNTO 0); -- 3 bits for 8 blocks
	signal offset : STD_LOGIC_VECTOR(4 DOWNTO 0); -- Byte-level offset within a block

    -- Cache related signals
   signal cache_index_offset : STD_LOGIC_VECTOR(7 DOWNTO 0);
	signal cache_data_out : STD_LOGIC_VECTOR(7 DOWNTO 0);
   signal cache_data_in : STD_LOGIC_VECTOR(7 DOWNTO 0);
	signal cache_write_enable : STD_LOGIC_VECTOR(0 DOWNTO 0);
	
    -- Memory related signals
	--signal memAddr : STD_LOGIC_VECTOR(15 downto 0);
	--signal wr_rd_m : STD_LOGIC;
   --signal mem_din : STD_LOGIC_VECTOR(7 downto 0);
   --signal mem_dout : STD_LOGIC_VECTOR(7 downto 0);
   signal mem_strb_buf : STD_LOGIC := '0';

   -- CPU related signals
   signal cpu_data_in : STD_LOGIC_VECTOR(7 downto 0);
	-- signal cpu_data_out : STD_LOGIC_VECTOR(7 downto 0);

    --Delays and Buffers
    signal clk_dly : STD_LOGIC := '0';
    signal RDY_buf : STD_LOGIC := '1';
	 signal memAddr_buf : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');

begin
	
   wrappedCache :	cacheMemory port map(
        clka => clk,
        wea => cache_write_enable,
        addra => cache_index_offset,
        dina => cache_data_in,
        douta => cache_data_out);
	
    mux : mux2to1  port map(
        din1 => cpu_data_out,
        din2 => mem_dout,
        dout => cache_data_in,
        sw => vbit);
    
    demux : demux2to1 port map(
        din => cache_data_out,
        dout1 => cpu_data_in,
        dout2 => mem_din,
        sw => dbit);
	
   process (clk)
	begin
		 if rising_edge(clk) then
			  if rst = '1' then
					-- Initialize all tag words to zero
					for i in 0 to 7 loop
						 tag_array(i).tag <= (others => '0'); -- Initialize tag to 0
						 tag_array(i).vbit <= '0';             -- Initialize vbit to 0
						 tag_array(i).dbit <= '0';             -- Initialize dbit to 0
					end loop;
			  end if;
			  -- Initialization
			  if ((RDY_buf = '1') and (cStrb = '1')) then
					tag <= cacheAddr(15 downto 8);
					index <= cacheAddr(7 downto 5);
					offset <= cacheAddr(4 downto 0);
					wen <= '0';
					RDY_buf <= '0';
					RDY <= '0';
				elsif(RDY_buf = '1') then
					RDY <= '1';
			  end if;

			  if RDY_buf = '0' then
					if tag_array(to_integer(unsigned(index))).vbit = '0' then
						 -- Fetch block from SDRAM
						 wr_rd_m <= '1';  -- Read from SDRAM
						 if mem_strb_buf = '0' then
							  vbit <= '1';
							  wen <= '1';
							  memAddr <= tag & index & "00000";  -- Starting address
							  memAddr_buf <= tag & index & "00000";
							  cache_index_offset <= index & "00000";  -- Cache address
							  memStrb <= '1';  -- Turn on strobe
							  mem_strb_buf <= '1';
						 elsif clk_dly = '1' then
							  wen <= '0';  -- Stop writing to cache
							  memStrb <= '0';  -- Disable SDRAM
							  mem_strb_buf <= '0';
							  clk_dly <= '0';
							  tag_array(to_integer(unsigned(index))).vbit <= '1';  -- Data is valid
							  tag_array(to_integer(unsigned(index))).tag <= tag;  -- Update tag
							  vbit <= '0';  -- Next data from CPU
						 elsif memAddr_buf(4 downto 0) = "11111" then
							  clk_dly <= '1';
						 else
							  memAddr <= memAddr_buf + '1';
							  memAddr_buf <= memAddr_buf + '1';
							  cache_index_offset <= cache_index_offset + '1';
						 end if;

					elsif tag_array(to_integer(unsigned(index))).vbit = '1' then
						 if tag_array(to_integer(unsigned(index))).tag = tag then
							  vbit <= '0';
							  dbit <= '0';
							  if clk_dly = '1' then
									RDY_buf <= '1';
									RDY <= '1';
									clk_dly <= '0';
									wen <= '0';
							  end if;
							  if wr_rd_c = '1' then
									cache_index_offset <= index & offset;  -- Reading
									wen <= '0';
									clk_dly <= '1';
							  else
									cache_index_offset <= index & offset;  -- Writing
									wen <= '1';
									tag_array(to_integer(unsigned(index))).dbit <= '1';
									clk_dly <= '1';
							  end if;

						 elsif tag_array(to_integer(unsigned(index))).tag /= tag then
							  if tag_array(to_integer(unsigned(index))).dbit = '0' then
									wr_rd_m <= '1';  -- Read from SDRAM
									if mem_strb_buf = '0' then
										 vbit <= '1';
										 wen <= '1';
										 memAddr <= tag & index & "00000";
										 memAddr_buf <= tag & index & "00000";
										 cache_index_offset <= index & "00000";
										 memStrb <= '1';
										 mem_strb_buf <= '1';
									elsif clk_dly = '1' then
										 wen <= '0';
										 memStrb <= '0';
										 mem_strb_buf <= '0';
										 clk_dly <= '0';
										 tag_array(to_integer(unsigned(index))).vbit <= '1';
										 tag_array(to_integer(unsigned(index))).tag <= tag;
										 vbit <= '0';
									else
										 if memAddr_buf(4 downto 0) = "11111" then
											  clk_dly <= '1';
										 else
											  memAddr <= memAddr_buf + '1';
											  memAddr_buf <= memAddr_buf + '1';
											  cache_index_offset <= cache_index_offset + '1';
										 end if;
									end if;

							  elsif tag_array(to_integer(unsigned(index))).dbit = '1' then
									wr_rd_m <= '0';  -- Write to SDRAM
									if mem_strb_buf = '0' then
										 dbit <= '1';
										 memAddr <= tag_array(to_integer(unsigned(index))).tag & index & "00000";
										 memAddr_buf <= tag_array(to_integer(unsigned(index))).tag & index & "00000";
										 cache_index_offset <= index & "00000";
										 memStrb <= '1';
										 mem_strb_buf <= '1';
									elsif clk_dly = '1' then
										 clk_dly <= '0';
										 mem_strb_buf <= '0';
										 memStrb <= '0';
										 tag_array(to_integer(unsigned(index))).dbit <= '0';
										 dbit <= '0';
									else
										 if memAddr_buf(4 downto 0) = "11111" then
											  clk_dly <= '1';
										 else
											  memAddr <= memAddr_buf + '1';
											  memAddr_buf <= memAddr_buf + '1';
											  cache_index_offset <= cache_index_offset + '1';
										 end if;
									end if;
							  end if;
						 end if;
					end if;
			  end if;
		 end if;
	end process;

end Behavioral;
