library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.NUMERIC_STD.all;

entity FIR is
    Port (
          clk               : in std_logic;
          reset             : in std_logic;
          
          -- signals from Pattern generator
          last_gen_pixel    : in std_logic_vector(3 downto 0);
          can_filter        : in std_logic;

          -- signals from VGA_driver
          VGA_is_in_display : in std_logic;
          x                 : in unsigned(9 downto 0);
          y                 : in unsigned(9 downto 0);

          FIR_pix           : out std_logic_vector(3 downto 0);
          wait_fir          : out std_logic
    );
end FIR;


architecture behavioral of FIR is

    type t_int_vector is array (0 to 8) of unsigned(2 downto 0);

    constant kernel                 : t_int_vector :=
    (
        to_unsigned(1, 3), to_unsigned(2, 3), to_unsigned(1, 3),
        to_unsigned(2, 3), to_unsigned(4, 3), to_unsigned(2, 3),
        to_unsigned(1, 3), to_unsigned(2, 3), to_unsigned(1, 3)
    );

    constant kern_size              : unsigned(1 downto 0) := to_unsigned(3, 2);
--    signal kernel_x_cnt             : std_logic;
--    signal kernel_y_cnt             : std_logic;

    -- line 1 buff signals
    signal line_1_buff_full         : std_logic;
    signal line_1_buff_empty        : std_logic;
    signal line_1_buff_pfull        : std_logic; -- set to 640 - 3
    signal line_1_buff_rd_en        : std_logic; -- set to 640 - 3

    -- line 2 buff signals
    signal line_2_buff_full         : std_logic;
    signal line_2_buff_empty        : std_logic;
    signal line_2_buff_pfull        : std_logic;
    signal line_2_buff_rd_en        : std_logic; -- set to 640 - 3


    -- pixels register for convolution
    -- pixels from line_1_buff
    signal p1_reg                   : std_logic_vector(7 downto 0);
    signal p2_reg                   : std_logic_vector(7 downto 0);
    signal p3_reg                   : std_logic_vector(7 downto 0);

    -- pixels from line_2_buff
    signal p4_reg                   : std_logic_vector(7 downto 0);
    signal p5_reg                   : std_logic_vector(7 downto 0);
    signal p6_reg                   : std_logic_vector(7 downto 0);

    -- latest gen pixels
    signal p7_reg                   : std_logic_vector(7 downto 0);
    signal p8_reg                   : std_logic_vector(7 downto 0);
    signal p9_reg                   : std_logic_vector(7 downto 0);
    
    -- pixels for convo calc
    -- according to position
    signal p1_calc                  : std_logic_vector(7 downto 0);
    signal p2_calc                  : std_logic_vector(7 downto 0);
    signal p3_calc                  : std_logic_vector(7 downto 0);

    -- pixels from line_2_buff
    signal p4_calc                  : std_logic_vector(7 downto 0);
    signal p5_calc                  : std_logic_vector(7 downto 0);
    signal p6_calc                  : std_logic_vector(7 downto 0);

    -- latest gen pixels
    signal p7_calc                  : std_logic_vector(7 downto 0);
    signal p8_calc                  : std_logic_vector(7 downto 0);
    signal p9_calc                  : std_logic_vector(7 downto 0);

--    signal pixel_to_compute_addr    : unsigned(10 downto 0);
--    signal tmp_pixel                : natural := 0;

    constant buffer_col_length      : unsigned(10 downto 0) := to_unsigned(1920, 11);
    constant buffer_depth           : unsigned(1 downto 0) := to_unsigned(3, 2);

    component fifo_generator_0 IS
        PORT (
            clk : IN STD_LOGIC;
            srst : IN STD_LOGIC;
            din : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            wr_en : IN STD_LOGIC;
            rd_en : IN STD_LOGIC;
            dout : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            full : OUT STD_LOGIC;
            empty : OUT STD_LOGIC;
            prog_full : OUT STD_LOGIC
        );
    END component;

begin

    -- Line buffer for the first line of the image
    LINE_1_BUFF : fifo_generator_0
    port map (
        clk => clk,
        srst => reset,
        din => p4_reg,
        wr_en => can_filter,
        rd_en => line_1_buff_rd_en,
        dout => p3_reg,
        full => line_1_buff_full,
        empty => line_1_buff_empty,
        prog_full => line_1_buff_pfull -- pass to '1' when FIFO count is 636
    );
    
    -- Line buffer for the first line of the image
    LINE_2_BUFF : fifo_generator_0
    port map (
        clk => clk,
        srst => reset,
        din => p7_reg,
        wr_en => can_filter,
        rd_en => line_2_buff_rd_en,
        dout => p6_reg,
        full => line_2_buff_full,
        empty => line_2_buff_empty,
        prog_full => line_2_buff_pfull -- pass to '1' when FIFO count is 636
    );

    
    -- shift registers logic
    process (clk, reset)
    begin
        if (reset = '1') then
            p1_reg <= (others => '0');
            p2_reg <= (others => '0');
--            p3_reg is reset via the FIFO

            p4_reg <= (others => '0');
            p5_reg <= (others => '0');
--            p6_reg is reset via the FIFO
            
            p7_reg <= (others => '0');
            p8_reg <= (others => '0');
            p9_reg <= (others => '0');

        elsif (rising_edge(clk)) then
            -- look at the RTL for details
            -- about these registers

            -- we shift the registers if we have something to display
            if (can_filter = '1') then
                p9_reg <= "0000" & last_gen_pixel;
                p8_reg <= p9_reg;
                p7_reg <= p8_reg;
                
                p5_reg <= p6_reg;
                p4_reg <= p5_reg;
                
                p2_reg <= p3_reg;
                p1_reg <= p2_reg;
            end if;
            
        end if;
    end process;
    
    -- combinatory logic
    
    -- the FIFOs are allowed to read only when the pattern generator
    -- has genered enough data ('can_filter' = '1') and the FIFO is full
    -- (the signal 'line_1_buff_pfull' is generated at 636 to anticipate FIFO
    -- read latency)
    line_1_buff_rd_en <= '1' when can_filter = '1' and line_1_buff_pfull = '1' else '0';
    line_2_buff_rd_en <= '1' when can_filter = '1' and line_2_buff_pfull = '1' else '0';


    -- check if the conv kernel is in the image
    p9_calc <= p9_reg when (x+1) < 640 and (y+1) < 480 and (x+1) >= 0 and (y+1) >= 0 else (others => '0'); -- (x+1, y+1)
    p8_calc <= p8_reg when (x) < 640 and (y+1) < 480 and (x) >= 0 and (y+1) >= 0 else (others => '0'); -- (x, y+1)
    p7_calc <= p7_reg when (x-1) < 640 and (y+1) < 480 and (x-1) >= 0 and (y+1) >= 0 else (others => '0'); -- (x-1, +y1)
    
    p6_calc <= p6_reg when (x+1) < 640 and (y) < 480 and (x+1) > 0 and (y) >= 0 else (others => '0'); -- (x+1,y)
    p5_calc <= p5_reg when (x) < 640 and (y) < 480 and (x) > 0 and (y) >= 0 else (others => '0'); -- (x,y)
    p4_calc <= p4_reg when (x-1) < 640 and (y) < 480 and (x-1) > 0 and (y) >= 0 else (others => '0'); -- (x-1, y)
    
    p3_calc <= p3_reg when (x+1) < 640 and (y-1) < 480 and (x+1) >= 0 and (y-1) >= 0 else (others => '0'); -- (x+1, y-1)
    p2_calc <= p2_reg when (x) < 640 and (y-1) < 480 and (x) >= 0 and (y-1) >= 0 else (others => '0'); -- (x, y-1)
    p1_calc <= p1_reg when (x-1) < 640 and (y-1) < 480 and (x-1) >= 0 and (y-1) >= 0 else (others => '0'); -- (x-1, y-1)
    
    -- compute convolution here
    FIR_pix <= std_logic_vector(
        shift_right(
            unsigned(p9_calc)                + shift_left(unsigned(p8_calc), 1) + unsigned(p7_calc) +
            shift_left(unsigned(p6_calc), 1) + shift_left(unsigned(p5_calc), 2) + shift_left(unsigned(p4_calc), 1) +
            unsigned(p3_calc)                + shift_left(unsigned(p2_calc), 1) + unsigned(p1_calc),
        4)(3 downto 0) -- we divide the sum by 16 (right shift of 4)
    );
    
    
    -- add a signal to tell the PG to wait for FIR to finished
    wait_fir <= '1' when ((y * 640) + x) >= ((480 * 640) -  642) else '0';

end behavioral;