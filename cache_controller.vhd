behtan
behtan
Idle

behtan — 10/08/2024 10:36 AM
my brain might be occupied...:D
i no think straight
Nickooo — 10/08/2024 10:37 AM
Occubrain :)
Baby think gay >:)
behtan — 10/08/2024 10:40 AM
it is also is creating a negative of the image for some reason
Image
Nickooo — 10/08/2024 10:43 AM
Ye it looks like
A triangle wave mapping
Ver dark stays dark, a bit lighter and it becomes light, a bit lighter and it starts to get dark again, so on
Is this with brightness?
behtan — 10/08/2024 10:46 AM
i check after class
:P
Nickooo — 10/08/2024 10:46 AM
Okeee
:P
Class over :?
behtan — 10/08/2024 10:49 AM
Not yet
Nickooo — 10/08/2024 10:49 AM
:<
behtan — 10/08/2024 10:50 AM
Vladislav doing iClickers
Nickooo — 10/08/2024 10:50 AM
Boooo
behtan — 10/08/2024 10:50 AM
We eat after thisv
?
Eat where?
Nickooo — 10/08/2024 10:50 AM
I has quizzzz
:(
behtan — 10/08/2024 10:50 AM
Oh noooo
I didnt realize
Okeee good luck!!
Lmk when quiz done :D
Nickooo — 10/08/2024 10:51 AM
I will :!!
She been doing this shit forever
Image
behtan — 10/09/2024 12:42 PM
----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    08:52:02 09/26/2024 
-- Design Name: 
Expand
message.txt
10 KB
Nickooo — 10/09/2024 8:03 PM
----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    08:52:02 09/26/2024 
-- Design Name: 
Expand
message.txt
14 KB
I DID THE DOOOO
I THINK IS GOOD :D
wait no hold
here i removed commented code
----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    08:52:02 09/26/2024 
-- Design Name: 
Expand
message.txt
13 KB
:>
behtan — 10/09/2024 8:05 PM
<:
Nickooo — 10/10/2024 8:07 PM
/* A simple echo server using TCP */
#include <stdio.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <sys/signal.h>
Expand
message.txt
6 KB
Nickooo — 10/10/2024 8:18 PM
bobo
babieeee
:!!:!:!:!:!:!!:!:!!
bobo :?
Nickooo — 10/10/2024 8:45 PM
BABIEEEEEEEE
baby baby baby
behtan — 10/10/2024 8:46 PM
mhm :? whats going on bobo :?:?
Nickooo — 10/10/2024 8:46 PM
are you todays date :?:?
behtan — 10/10/2024 8:46 PM
bobo bobo bobo
Nickooo — 10/10/2024 8:46 PM
bc you're 10/10 ;>>>
behtan — 10/10/2024 8:46 PM
mmm
AWWWWWWWWWWWWW
﻿
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

    -- Cache related signals
    signal cache_index_offset : STD_LOGIC_VECTOR(7 DOWNTO 0);
	signal cache_data_out : STD_LOGIC_VECTOR(7 DOWNTO 0);
    signal cache_data_in : STD_LOGIC_VECTOR(7 DOWNTO 0);
	signal cache_write_enable : STD_LOGIC_VECTOR(0 DOWNTO 0);
	
    -- Memory related signals
	signal memAddr : STD_LOGIC_VECTOR(15 downto 0);
	signal wr_rd_m : STD_LOGIC;
    signal mem_din : STD_LOGIC(7 downto 0):
    signal mem_dout : STD_LOGIC(7 downto 0):
    signal mem_strb_buf : STD_LOGIC := '0';

    -- CPU related signals
    signal cpu_data_in : STD_LOGIC_VECTOR(7 downto 0);
    signal cpu_data_out : STD_LOGIC_VECTOR(7 downto 0);

    --Delays and Buffers
    signal clk_dly : STD_LOGIC := '0';
    signal RDY_buf : STD_LOGIC := '1';

begin
	
	component wrapped_cacheMemory
	Port map(
        clka => clk,
        wea => cache_write_enable,
        --addra => addr(7 DOWNTO 0), -- Using lower 8 bits as address for cache
        addra => cache_index_offset,
        dina => data_in,
        douta => cache_data_out);
	end component;
	
	component SDRAM_controller is
    Port map(
        clk : in  STD_LOGIC;
		MemAddr_SDRAM => memAddr;
        wr_rd_SDRAM => wr_rd_m;
        --MemStrb_SDRAM : in  STD_LOGIC;
        Din_SDRAM => mem_din;
        Dout_SDRAM => mem_dout;
    );
	end component SDRAM_controller;

    component mux2to1 is
    Port map(
        din1 => cpu_data_out;
        din2 => mem_dout;
        dout => cache_data_in;
        sw => vbit;
    );
    end component;

    component demux1to2 is
    Port map(
        din => cache_data_in;
        dout1 => cpu_data_in;
        dout2 => mem_din;
        sw => dbit;
    );
    end component;
	
   process (clk)
		begin
        if rising_edge(clk) then
            --initializaion
            if RDY_buf = '1' and cStrb = "1" then
                -- extract tag, index, and offset, set RDY and cache write to low
                tag <= cacheAddr(15 downto 8);
                index <= cacheAddr(7 downto 5);
                offset <= cacheAddr(4 downto 0);
                wen <= '0';
                RDY_buf <= '0';
                RDY <= '0';
            end if;

            --start of procedure
            if RDY_buf = '0' then
                -- check if vbit is 0, then it is a miss
                if tag_array(index).vbit = "0" then             --fetch block from SDRAM
                    hit <= "0";		--it is a miss
                    -- Block is invalid. 
                    -- Fetch block from main memory, update tag, set vBit to 1, write to cache.

                    wr_rd_m <= "1"; 				            --read from SDRAM
                    if mem_strb_buf = '0' then                  --start point of data transfer
                        vbit <= '1';                            --make sure data comes from SDRAM and not CPU
                        wen <= '1';                             --enable writing to cache
                        memAddr <= tag&index&"00000";           --send block starting address to memory
                        cache_index_offset <= index&"00000";    --send block starting address to cache
                        memStrb <= '1';                         --turn on strobe to allow writing to SDRAM
                        mem_strb_buf <= '1';
                    elsif clk_dly = '1' then                    --after last cycle, stop data transfer
                        wen <= '0';                             --stop writing to cache
                        memStrb <= '0';                         --disable SDRAM
                        mem_strb_buf <= '0';
                        clk_dly <= '0';
                        tag_array(index).vbit <= '1';           --data in cache is now valid
                        tag_array(index).tag <= tag;            --upddate tag
                        vbit <= '0';                            --next data transfer will now come from CPU
                    elsif memAddr(4 downto 0) = "11111" then    --if last cycle, raise flag to stop data transfer on NEXT clock cycle, so no data is missed
                        clk_dly <= '1';
                    else                                        --normal: every clock cycle, increment address locations
                        memAddr <= memAddr + '1';
                        cache_index_offset <= cache_index_offset + '1';
                    end if;

                else if tag_array(index).vbit = "1" then                --Vbit in controller is 1
                    if tag_array(index).tag = tag then                  --If tags match, then perform operation and exit
                        hit = "1";
                        vbit <= '0';
                        dbit <= '0';
                        if clk_dly = '1' then                       --after clock delay, set ready signal back to high
                            RDY_buf <= '1';
                            RDY <= '1';
                            clk_dly <= '0';
                            wen <= '0';
                        end if;
                        if wr_rd_c = "1" then                       --if reading from cache
                            cache_index_offset <= index&offset;
                            wen <= '0';
                            clk_dly <= '1';                         --wait one clock cycle for data transfer
                        else                                        --if writing to cache
                            cache_index_offset <= index&offset;
                            wen <= '1';
                            tag_array(index).dbit <= '1';
                            clk_dly <= '1';                         --wait one clock cycle for data transfer
                        end if;

                    elsif tag_array(index).tag /= tag then              --If tags do not match, then get correct block from SDRAM
                        hit = "0";

                        if tag_array(index).dbit = "0" then             --If cache memory is NOT altered, then immediately get new block from SDRAM
                            wr_rd_m <= "1"; 				            --read from SDRAM
                            if mem_strb_buf = '0' then                  --start point of data transfer
                                vbit <= '1';                            --make sure data comes from SDRAM and not CPU
                                wen <= '1';                             --enable writing to cache
                                memAddr <= tag&index&"00000";           --send block starting address to SDRAM
                                cache_index_offset <= index&"00000";    --send block starting address to cache
                                memStrb <= '1';                         --turn on strobe to allow writing to SDRAM
                                mem_strb_buf <= '1';
                            elsif clk_dly = '1' then                    --after last cycle, stop data transfer
                                wen <= '0';                             --stop writing to cache
                                memStrb <= '0';                         --disable SDRAM
                                mem_strb_buf <= '0';
                                clk_dly <= '0';
                                tag_array(index).vbit <= '1';           --data in cache is now valid
                                tag_array(index).tag <= tag;            --tags should now match
                                vbit <= '0';                            --next data transfer will now come from CPU
                            else
                                if memAddr(4 downto 0) = "11111" then   --if last cycle, raise flag to stop data transfer on NEXT clock cycle, so no data is missed
                                    clk_dly <= '1';
                                else                                    --normal: every clock cycle, increment address locations
                                    memAddr <= memAddr + '1';
                                    cache_index_offset <= cache_index_offset + '1';
                                end if;
                            end if;
                        else if tag_array(index).dbit = "1" then        -- If cache memory IS altered, write block back to SDRAM first
                            --Block is valid and dirty -> Write back to memory
                            wr_rd_m <= "0"; 				            --write to SDRAM
                            if mem_strb_buf = '0' then                  --start point of data transfer
                                dbit <= '1';                            --make sure data from cache goes to SDRAM and not CPU
                                memAddr <= tag_array(index).tag&index&"00000";           --send block starting address to SDRAM
                                cache_index_offset <= index&"00000";    --send block starting address to cache
                                memStrb <= '1';                         --turn on strobe to allow writing to SDRAM
                                mem_strb_buf <= '1';
                            elsif clk_dly = '1' then                    --after last cycle, stop data transfer
                                clk_dly <= '0';
                                mem_strb_buf <= '0';
                                memStrb <= '0';
                                tag_array(index).dbit <= '0';
                                -- tag_array(index).vbit <= '0';
                                dbit <= '0';
                            else
                                if memAddr(4 downto 0) = "11111" then   --if last cycle, raise flag to stop data transfer on NEXT clock cycle, so no data is missed
                                    clk_dly <= '1';
                                else                                    --normal: every clock cycle, increment address locations
                                    memAddr <= memAddr + '1';
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
