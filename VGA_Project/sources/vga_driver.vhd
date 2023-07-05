library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity vga_driver is
    Port (
        -- inputs
        clk                     : in std_logic;
        reset                   : in std_logic;
        RGB_pixel               : in std_logic_vector(11 downto 0);
        can_start_printing      : in std_logic;

        -- outputs
        -- signals handling color intensity
        int_red                 : out std_logic_vector(3 downto 0);
        int_green               : out std_logic_vector(3 downto 0);
        int_blue                : out std_logic_vector(3 downto 0);

        -- signals handling frame printing
        vsync                   : out std_logic;
        hsync                   : out std_logic;

        -- indicate if the driver is printing on screen
        -- (for the pattrern generator)
        is_in_display           : out std_logic;
        start_gen_next_frame    : out std_logic;

        x : out unsigned(9 downto 0);
        y : out unsigned(9 downto 0)
    );
end vga_driver;

architecture Behavioral of vga_driver is

    -- internal signals to generate SYNC pulses
    signal h_is_in_display          : std_logic;
    signal v_is_in_display          : std_logic;
    signal is_in_display_in         : std_logic;
    signal cmp_end_line             : std_logic;

    -- counters signal
    signal col_cnt                  : unsigned(9 downto 0);
    signal row_cnt                  : unsigned(9 downto 0);

begin

    process(clk, reset)
    begin
        if (reset = '1') then
            col_cnt <= to_unsigned(0, 10);
            row_cnt <= to_unsigned(0, 10);

        elsif (rising_edge(clk)) then
            -- increment the cols at each clock cycle
            -- if the FIFO is not busy
            if (cmp_end_line = '1') then
                col_cnt <= to_unsigned(0, 10);
            elsif (can_start_printing = '1' or (row_cnt * 800 + col_cnt) > 0) then
                col_cnt <= col_cnt + 1;
            end if;

            if (cmp_end_line = '1') then
                if (row_cnt = 524) then
                    -- we are at the end of the frame -> reset counter
                    row_cnt <= to_unsigned(0, 10);
                else
                    -- increment the rows when col_cnt = 639
                    row_cnt <= row_cnt + 1;
                end if;
            end if;

        end if;
    end process;

    -- combinatory logic

    -- cols logic 
    hsync <= '1' when (col_cnt >= 656) and (col_cnt < 752) else '0'; -- add delay logic
    h_is_in_display <= '1' when (col_cnt < 640) else '0';
    cmp_end_line <= '1' when col_cnt = 799 else '0';

    -- rows logic 
    vsync <= '1' when (row_cnt >= 490) and (row_cnt < 492) else '0'; -- add delay logic
    v_is_in_display <= '1' when (row_cnt < 480) else '0';

    is_in_display_in <= h_is_in_display and v_is_in_display;
    is_in_display <= is_in_display_in;

    -- set output pixel intensity
    int_red <= RGB_pixel(11 downto 8) when is_in_display_in = '1' else (others => '0');
    int_green <= RGB_pixel(7 downto 4) when is_in_display_in = '1' else (others => '0');
    int_blue <= RGB_pixel(3 downto 0) when is_in_display_in = '1' else (others => '0');

    -- inform the pattern generator that the vertical
    -- back porch is nearly finish, and can start to
    -- to generate the next frame
    start_gen_next_frame <= '1' when ((row_cnt * 800) + col_cnt) >= ((525 * 800) -  642) else '0';--> 419_197 else '0';

    -- pass the counter to the FIR to compute
    -- delay signals
    x <= col_cnt;
    y <= row_cnt;

end Behavioral;
