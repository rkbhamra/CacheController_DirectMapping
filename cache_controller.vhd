library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Cache_Controller is
    Port (
        clk : in  STD_LOGIC;
        rst : in  STD_LOGIC;
        addr : in  STD_LOGIC_VECTOR(15 downto 0);
        wr_rd : in  STD_LOGIC; -- 1 for read, 0 for write
        data_in : in  STD_LOGIC_VECTOR(7 downto 0);
        data_out : out  STD_LOGIC_VECTOR(7 downto 0);
        hit : out  STD_LOGIC -- Cache hit signal
    );
end Cache_Controller;

architecture Behavioral of Cache_Controller is

    -- Define the tag word structure
    TYPE tag_word IS RECORD
        tag  : STD_LOGIC_VECTOR(7 DOWNTO 0); -- Tag field
        vbit : STD_LOGIC; -- Valid bit
        dbit : STD_LOGIC; -- Dirty bit
    END RECORD;

    -- Array to hold tag words for each cache block (8 blocks)
    SIGNAL tag_array : ARRAY(0 TO 7) OF tag_word;

    -- Signals to extract the tag, index, and offset from address
    SIGNAL tag    : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL index  : STD_LOGIC_VECTOR(2 DOWNTO 0); -- 3 bits for 8 blocks
    SIGNAL offset : STD_LOGIC_VECTOR(4 DOWNTO 0); -- Byte-level offset within a block
    
    -- Cache memory instantiation
    COMPONENT cacheMemory
        PORT (
            clka : IN STD_LOGIC;
            wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
            addra : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            dina : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
        );
    END COMPONENT;

    SIGNAL cache_data_out : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL cache_write_enable : STD_LOGIC_VECTOR(0 DOWNTO 0);

begin

    -- Extract tag, index, and offset from the input address
    tag <= addr(15 DOWNTO 8);    -- Upper 8 bits as tag
    index <= addr(7 DOWNTO 5);   -- Middle 3 bits as index
    offset <= addr(4 DOWNTO 0);  -- Lower 5 bits as offset

    -- Cache memory instance
    cache_instance : cacheMemory
        PORT MAP (
            clka => clk,
            wea => cache_write_enable,
            addra => addr(7 DOWNTO 0), -- Using lower 8 bits as address for cache
            dina => data_in,
            douta => cache_data_out
        );

    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                -- Reset the cache controller and tags
                for i in 0 to 7 loop
                    tag_array(i).vbit <= '0'; -- Invalidate all blocks
                    tag_array(i).dbit <= '0'; -- Mark all blocks as clean
                    tag_array(i).tag <= (others => '0'); -- Clear tags
                end loop;
                hit <= '0';
            else
                -- Check if the block is valid and tags match
                if tag_array(to_integer(unsigned(index))).vbit = '1' then
                    if tag_array(to_integer(unsigned(index))).tag = tag then
                        -- Cache hit
                        hit <= '1';
                        if wr_rd = '1' then
                            -- Read hit: output data from cache
                            data_out <= cache_data_out;
                        else
                            -- Write hit: write to cache, mark dirty
                            cache_write_enable <= "1";
                            tag_array(to_integer(unsigned(index))).dbit <= '1'; -- Mark dirty
                        end if;
                    else
                        -- Cache miss: handle block replacement
                        hit <= '0';
                        -- Replace logic goes here (fetch from memory)
                        -- Update tag, set vbit and handle dirty bit logic if needed
                    end if;
                else
                    -- Cache miss: block invalid
                    hit <= '0';
                    -- Fetch from memory, update tag, set vbit to 1, and handle writing
                    tag_array(to_integer(unsigned(index))).tag <= tag;
                    tag_array(to_integer(unsigned(index))).vbit <= '1';
                    tag_array(to_integer(unsigned(index))).dbit <= '0'; -- Mark as clean
                end if;
            end if;
        end if;
    end process;

end Behavioral;
