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

entity pattern_generator_FIR is
    Port (
        -- inputs
        clk                     : in std_logic;
        reset                   : in std_logic;
        VGA_is_in_display       : in std_logic;
        start_gen_next_frame    : in std_logic;
        wait_fir                : in std_logic;

        -- outputs
        -- signals handling color intensity
        gen_pixel               : out std_logic_vector(11 downto 0);
        can_start_printing      : out std_logic;
        can_filter              : out std_logic
    );
end pattern_generator_FIR;

architecture Behavioral of pattern_generator_FIR is
    signal cmp_end_line             : std_logic;
    signal cmp_end_frame            : std_logic;

    -- counters signal
    -- cols counter
    signal col_cnt                  : unsigned(9 downto 0);
    signal row_cnt                  : unsigned(9 downto 0);

    signal col_mux_cmd              : std_logic := '0';

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
            elsif (col_mux_cmd = '1') then
                col_cnt <= col_cnt + 1;
            end if;

            -- rows counter logic
            -- clear the row count when col_cnt = 639 and row_cnt = 479
            if (cmp_end_frame = '1') then
                row_cnt <= to_unsigned(0, 10);
            -- increment the rows when col_cnt = 639
            elsif (cmp_end_line = '1') then
                row_cnt <= row_cnt + 1;
            end if;


        end if;
    end process;

    -- combinatory logic

    -- tell the pattern generator that he can generate pixels
    -- when we are in the VGA display area or when we are in the vertical back porch 
    col_mux_cmd <= '1' when start_gen_next_frame = '1'
                        or (VGA_is_in_display = '1' and wait_fir = '0') else '0';
    
    -- let know the FIR that it can begin filtering
    can_filter <= col_mux_cmd;

    --- LUT begin
--    gen_pixel <= x"111" when col_cnt = 0 and row_cnt = 0
--        else x"222" when col_cnt = 0 and row_cnt = 1
--        else x"333" when col_cnt = 0 and row_cnt = 2
--        else x"F00" when col_cnt < 160
--        else x"0F0" when col_cnt >= 160 and col_cnt < 320
--        else x"00F" when col_cnt >= 320 and col_cnt < 480
--        else x"FFF" when col_cnt >= 480 and col_cnt < 640;
    gen_pixel <= (others => '1') when (col_cnt(5) = '0' xor row_cnt(5) = '0')
                else (others => '0');
    --- LUT end

    cmp_end_line <= '1' when col_cnt = 639 else '0';
    cmp_end_frame <= '1' when row_cnt = 479 and col_cnt = 639 else '0';

    can_start_printing <= '1' when ((row_cnt * 640 + col_cnt)) > 641;-- or start_gen_next_frame = '1' else '0';

end Behavioral;
