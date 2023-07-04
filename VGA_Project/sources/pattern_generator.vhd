--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;
--use ieee.std_logic_unsigned.all;
--use ieee.numeric_std.all;

---- Uncomment the following library declaration if using
---- arithmetic functions with Signed or Unsigned values
----use IEEE.NUMERIC_STD.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx leaf cells in this code.
----library UNISIM;
----use UNISIM.VComponents.all;

--entity pattern_generator is
--    Port (
--        -- inputs
--        clk                 : in std_logic;
--        reset               : in std_logic;
--<<<<<<< Updated upstream
--        vga_hsync           : in std_logic;
        
--        -- outputs
--        -- signals handling color intensity
--        gen_pixel             : out std_logic_vector(11 downto 0);
--        gen_pixel_en          : out std_logic;
--        -- signals handling frame printing
--        gen_pixel_addr        : out std_logic_vector(12 downto 0) -- the addr of the generated pixel to store in the buffer
--=======
--        VGA_is_in_display   : in std_logic;
        
--        -- outputs
--        -- signals handling color intensity
--        gen_pixel             : out std_logic_vector(11 downto 0)
-->>>>>>> Stashed changes
--    );
--end pattern_generator;

--architecture Behavioral of pattern_generator is
--<<<<<<< Updated upstream

--=======
-->>>>>>> Stashed changes
--    signal cmp_end_line             : std_logic;
--    signal cmp_end_frame            : std_logic;
    
--    -- counters signal
--    -- cols counter
--    signal col_cnt                  : unsigned(9 downto 0);
--    signal row_cnt                  : unsigned(9 downto 0);
    
--    -- LUT signals for 'chess board' test pattern
--    signal square                   : std_logic := '1';
--    signal change_square            : unsigned(9 downto 0);
--    signal square1                  : std_logic := '1';
--    signal square2                  : std_logic := '0';
--    signal invert_row               : std_logic := '0';
--<<<<<<< Updated upstream
--    constant square_width           : positive := 40;
    
--    -- detect rising edge of VGA HSYNC signal
--    -- from clkB clock domain
--    signal PG_hsync_prev            : std_logic;
--    signal PG_hsync                 : std_logic;
    
--    signal hsync_cnt                : unsigned(3 downto 0);
--    signal cmp_hsync_cnt            : std_logic;
--    signal addr_cnt                 : unsigned(19 downto 0);
--    signal gen_pixel_addr_in        : unsigned(19 downto 0);
--    signal gen_pixel_en_in          : std_logic;
    
--=======
--    signal row_mod_prev             : std_logic := '0';
--    signal row_mod_stable           : std_logic := '0';
--    constant square_width           : unsigned(5 downto 0) := to_unsigned(39, 6);

-->>>>>>> Stashed changes
--begin

--    process(clk, reset)
--    begin
--        if (reset = '1') then
--            col_cnt <= to_unsigned(0, 10);
--            row_cnt <= to_unsigned(0, 10);
--            PG_hsync_prev <= '0';
--            PG_hsync <= '0';
--            hsync_cnt <= to_unsigned(0, 4);
            
--        elsif (rising_edge(clk)) then
            
--            -- detect rising edge of HSYNC
--            PG_hsync_prev <= vga_hsync;
--            PG_hsync <= not PG_hsync_prev and vga_hsync;
            
--            -- HSYNC counter logic
--            if (cmp_hsync_cnt = '1') then
--                hsync_cnt <= to_unsigned(0, 4);
--            else
--                if (PG_hsync = '1') then
--                    hsync_cnt <= hsync_cnt + 1;
--                end if;
--            end if;
            
--            -- cols counter logic
--            if (cmp_end_line = '1') then
--                col_cnt <= to_unsigned(0, 10);
--            -- increment the cols at each clock cycle
--            -- if the FIFO is not full or not busy
--<<<<<<< Updated upstream
--            elsif (gen_pixel_en_in = '1') then
--=======
--            elsif (VGA_is_in_display = '1') then
-->>>>>>> Stashed changes
--                col_cnt <= col_cnt + 1;
--            end if;

--            -- rows counter logic
--            if (cmp_end_frame = '1') then
--                row_cnt <= to_unsigned(0, 10);
--            -- increment the rows when col_cnt = 639
--            elsif (cmp_end_line = '1') then
--                row_cnt <= row_cnt + 1;
--            end if;

--        end if;
--    end process;

--    -- combinatory logic

--    --- LUT begining
--<<<<<<< Updated upstream
--    --- RGB test pattern
----    gen_pixel <= x"000" when col_cnt < 320
----        else x"FFF";
--    --- LUT end

--    --- LUT begining
--    --- RGB test pattern
--    gen_pixel <= x"F00" when col_cnt < 160
--        else x"0F0" when col_cnt >= 160 and col_cnt < 320
--        else x"00F" when col_cnt >= 320 and col_cnt < 480
--        else x"FFF" when col_cnt >= 480 and col_cnt < 640;
--    --- LUT end
    
--    --- LUT begining
--    --- RGB test pattern
--=======
----    gen_pixel <= x"F00" when col_cnt < 160
----        else x"0F0" when col_cnt >= 160 and col_cnt < 320
----        else x"00F" when col_cnt >= 320 and col_cnt < 480
----        else x"FFF" when col_cnt >= 480 and col_cnt < 640;
--    --- LUT end
    
--    --- LUT begining
--    -- RGB test pattern
-->>>>>>> Stashed changes
----    gen_pixel <= (others => square);
    
--    -- alternate square on row each 40 cols
----    change_square <= col_cnt mod square_width; -- square_width = 40
----    square <= not square when change_square = 0 else square;
    
--<<<<<<< Updated upstream
--    -- alternate square on col each 40 rows
----    invert_row <= '1' when row_cnt mod square_width = 0 else '0';
    
----    process(col_cnt, row_cnt)
----    begin
----        -- alternate square on row each 40 cols
----        if (col_cnt mod square_width = 0) then
----            square <= not square;
----        end if;
        
----        -- alternate square on col each 40 rows
----        if (row_cnt mod square_width = 0) then
----            invert_row <= not invert_row;
--=======
--    --alternate square on col each 40 rows
----    invert_row <= '1' when row_cnt mod square_width = 0 else '0';
    
----    process(clk, reset, col_cnt)
----    begin
----        if (reset = '1') then
----            square <= '0';
----        elsif(rising_edge(clk)) then
----            -- alternate square on row each 40 cols
----            if (col_cnt = 0) then
----                square <= invert_row;
----            elsif (col_cnt mod square_width = 0) then
----                square <= not square;
----            end if;
----        end if;
----    end process;
    
----    process(clk, reset, row_cnt)
----    begin
----        if (reset = '1') then
----            invert_row <= '0';
----        elsif(rising_edge(clk)) then
        
----            -- begin rising edge detection of row_cnt mod 40 = 0
----            if (row_cnt mod square_width = 0) then 
----                row_mod_prev <= '1';
----            else
----                row_mod_prev <= '0';
----            end if;
            
----            if (row_cnt mod square_width = 0 and row_mod_prev = '0') then 
----                row_mod_stable <= '1';
----            else
----                row_mod_stable <= '0';
----            end if;
----           -- end rising edge detection of row_cnt mod 40 = 0

        
----            -- alternate square on col each 40 rows
----            if (row_cnt /= 0 and row_mod_stable = '1') then
----                invert_row <= not invert_row;
----            end if;
-->>>>>>> Stashed changes
----        end if;
----    end process;

----    gen_pixel <= (others => square);-- when invert_row = '0' else (others => not square);
    
--<<<<<<< Updated upstream
--    --- LUT end

--    cmp_end_line <= '1' when col_cnt = 639 else '0';
--    cmp_end_frame <= '1' when row_cnt = 479 and col_cnt = 639 else '0';

--    -- HSYNC counter logic
--    -- we restart the pattern generation when the vga driver
--    -- has finished to print the image on screen
--    cmp_hsync_cnt <= '1' when hsync_cnt = 12 else '0';

--    --
----    FIFO_wr_en <= '1' when (col_cnt < 640 and row_cnt < 480) and (FIFO_full = '0') else '0';
--    addr_cnt <= (row_cnt * 640 + col_cnt);
----    gen_pixel_addr_in <= std_logic_vector(addr_cnt mod 7040);
--    gen_pixel_addr_in <= addr_cnt mod 7040;
--    gen_pixel_addr <= std_logic_vector(gen_pixel_addr_in(12 downto 0));
    
--    gen_pixel_en_in <= '1' when ((addr_cnt mod 7040) > 0) or (addr_cnt = 0) or (cmp_hsync_cnt = '1') else '0';
--    gen_pixel_en <= gen_pixel_en_in;
--=======
--    gen_pixel <= (others => '1') when (col_cnt(5) = '0' xor row_cnt(5) = '0') else (others => '0');
    
--    --- LUT end
    
    
--    cmp_end_line <= '1' when col_cnt = 639 else '0';
--    cmp_end_frame <= '1' when row_cnt = 479 and col_cnt = 639 else '0';
-->>>>>>> Stashed changes

--end Behavioral;
