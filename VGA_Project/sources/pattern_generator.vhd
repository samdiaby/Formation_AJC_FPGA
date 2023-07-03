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
        --VGA_VSYNC           : in std_logic_vector(11 downto 0);
        
        -- outputs
        -- signals handling color intensity
        gen_pixel             : out std_logic_vector(11 downto 0)
        -- signals handling frame printing
        --requested_pixel     : out std_logic_vector(11 downto 0); -- get the requested pixel from a frame buffer
    );
end pattern_generator;

architecture Behavioral of pattern_generator is

--    signal h_is_in_display          : std_logic;
--    signal v_is_in_display          : std_logic;
--    signal is_in_display            : std_logic;
    signal cmp_end_line             : std_logic;
    signal cmp_end_frame            : std_logic;


    
    -- counters signal
    -- cols counter
    signal col_cnt                  : unsigned(9 downto 0);
    signal row_cnt                  : unsigned(9 downto 0);
    

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
            elsif VGA_is_in_display = '1' then
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
    
    --- LUT begining
    gen_pixel <= x"F00" when col_cnt < 160
        else x"0F0" when col_cnt >= 160 and col_cnt < 320
        else x"00F" when col_cnt >= 320 and col_cnt < 480
        else x"FFF" when col_cnt >= 480 and col_cnt < 640;
    --- LUT end
    
    cmp_end_line <= '1' when col_cnt = 639 else '0';
    cmp_end_frame <= '1' when row_cnt = 479 and col_cnt = 639 else '0';
        

end Behavioral;
