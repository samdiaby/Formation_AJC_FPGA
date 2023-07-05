library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity pattern_generator is
    Port (
        -- inputs
        clk                 : in std_logic;
        reset               : in std_logic;
        VGA_is_in_display   : in std_logic;
        
        -- outputs
        -- signals handling color intensity
        gen_pixel             : out std_logic_vector(11 downto 0)
    );
end pattern_generator;

architecture Behavioral of pattern_generator is
    signal cmp_end_line             : std_logic;
    signal cmp_end_frame            : std_logic;
    
    -- counters signal
    -- cols counter
    signal col_cnt                  : unsigned(9 downto 0);
    signal row_cnt                  : unsigned(9 downto 0);
    
    -- LUT signals for 'chess board' test pattern
    signal square                   : std_logic := '1';
    signal change_square            : unsigned(9 downto 0);
    signal square1                  : std_logic := '1';
    signal square2                  : std_logic := '0';
    signal invert_row               : std_logic := '0';
    signal row_mod_prev             : std_logic := '0';
    signal row_mod_stable           : std_logic := '0';
    constant square_width           : unsigned(5 downto 0) := to_unsigned(39, 6);

begin

    process(clk, reset)
    begin
        if (reset = '1') then
            col_cnt <= to_unsigned(0, 10);
            row_cnt <= to_unsigned(0, 10);

        elsif (rising_edge(clk)) then
            -- cols counter logic
            if (cmp_end_line = '1') then
                col_cnt <= to_unsigned(0, 10);
            -- increment the cols at each clock cycle
            -- if the FIFO is not full or not busy
            elsif (VGA_is_in_display = '1') then
                col_cnt <= col_cnt + 1;
            end if;

            -- rows counter logic
            if (cmp_end_frame = '1') then
                row_cnt <= to_unsigned(0, 10);
            -- increment the rows when col_cnt = 639
            elsif (cmp_end_line = '1') then
                row_cnt <= row_cnt + 1;
            end if;

        end if;
    end process;

    -- combinatory logic
    
    --- LUT begin
    gen_pixel <= (others => '1') when (col_cnt(5) = '0' xor row_cnt(5) = '0') else (others => '0');
    --- LUT end
    
    
    cmp_end_line <= '1' when col_cnt = 639 else '0';
    cmp_end_frame <= '1' when row_cnt = 479 and col_cnt = 639 else '0';

end Behavioral;
