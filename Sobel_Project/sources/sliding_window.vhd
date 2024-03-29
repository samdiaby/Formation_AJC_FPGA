library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.NUMERIC_STD.all;

entity sliding_window is
    generic(
        PX_SIZE             : integer := 8;        -- taille d'un pixel
        IMG_HEIGHT          : natural;
        IMG_WIDTH           : natural
    );
    Port (
        clk                     : in std_logic;
        reset                   : in std_logic;
        
        -- signals from image reader
        latest_pixel            : in std_logic_vector(PX_SIZE-1 downto 0);
        pixel_valid             : in std_logic;
        
        -- FIR_pix           : out std_logic_vector(7 downto 0);
        -- pixels register for convolution
        -- pixels from line_1_buff
        p1_reg, p2_reg, p3_reg  : out std_logic_vector(PX_SIZE-1 downto 0);
        -- pixels from line_2_buff
        p4_reg, p5_reg, p6_reg  : out std_logic_vector(PX_SIZE-1 downto 0);
        -- latest gen pixels
        p7_reg, p8_reg, p9_reg  : out std_logic_vector(PX_SIZE-1 downto 0);
        
        can_compute             : out std_logic
    );
end sliding_window;


architecture behavioral of sliding_window is

    -- signals to handle counter / delays
    signal x                            : natural;-- range 0 to IMG_WIDTH; -- col_cnt
    signal y                            : natural;-- range 0 to IMG_HEIGHT; -- row_cnt
    signal idx_in_img                   : natural;-- range 0 to ((IMG_HEIGHT + 2) * IMG_WIDTH);
    signal cmp_end_frame                : std_logic;
    signal cmp_end_line                 : std_logic;
    constant MIN_IDX_BEFORE_COMP        : natural := (IMG_WIDTH + 2); -- min index before conv computation
    constant MAX_IDX_FOR_COMP           : natural := ((IMG_HEIGHT + 1) * IMG_WIDTH) + 2; -- min index before conv computation


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
    signal p1_reg_in, p2_reg_in, p3_reg_in  : std_logic_vector(7 downto 0);
    -- pixels from line_2_buff
    signal p4_reg_in, p5_reg_in, p6_reg_in  : std_logic_vector(7 downto 0);
    -- latest gen pixels
    signal p7_reg_in, p8_reg_in, p9_reg_in  : std_logic_vector(7 downto 0);


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

    -- Line buffer for the second line of the image
    LINE_1_BUFF : fifo_generator_0
    port map (
        clk => clk,
        srst => reset,
        din => p4_reg_in,
        wr_en => pixel_valid,
        rd_en => line_1_buff_rd_en,
        dout => p3_reg_in,
        full => line_1_buff_full,
        empty => line_1_buff_empty,
        prog_full => line_1_buff_pfull -- pass to '1' when FIFO count is 61
    );
    
    -- Line buffer for the first line of the image
    LINE_2_BUFF : fifo_generator_0
    port map (
        clk => clk,
        srst => reset,
        din => p7_reg_in,
        wr_en => pixel_valid,
        rd_en => line_2_buff_rd_en,
        dout => p6_reg_in,
        full => line_2_buff_full,
        empty => line_2_buff_empty,
        prog_full => line_2_buff_pfull -- pass to '1' when FIFO count is 61
    );

    
    -- shift registers logic
    process (clk, reset)
    begin
        if (reset = '1') then
            p1_reg_in <= (others => '0');
            p2_reg_in <= (others => '0');
--            p3_reg is reset via the FIFO

            p4_reg_in <= (others => '0');
            p5_reg_in <= (others => '0');
--            p6_reg is reset via the FIFO
            
            p7_reg_in <= (others => '0');
            p8_reg_in <= (others => '0');
            p9_reg_in <= (others => '0');

            -- reset counters
            x <= 0;
            y <= 0;

        elsif (rising_edge(clk)) then
            -- look at the RTL for details
            -- about these registers

            -- we shift the registers if we have something to display
            if (pixel_valid = '1') then
                p9_reg_in <= latest_pixel;
                p8_reg_in <= p9_reg_in;
                p7_reg_in <= p8_reg_in;
                
                p5_reg_in <= p6_reg_in;
                p4_reg_in <= p5_reg_in;
                
                p2_reg_in <= p3_reg_in;
                p1_reg_in <= p2_reg_in;
            end if;
            
            -- col/row counters logic
            -- col counter logic
            if ((y < (IMG_HEIGHT + 2 - 1) and cmp_end_line = '1') or cmp_end_frame = '1') then
                x <= 0;
            elsif (pixel_valid = '1') then
                x <= x + 1;
            end if;
            
            -- row counter logic
            if (cmp_end_frame = '1') then
                y <= 0;
            elsif (cmp_end_line = '1') then
                y <= y + 1;
            end if;
            
        end if;
    end process;
    
    -- combinatory logic
    
    -- the FIFOs are allowed to read only when we have read enough data
    -- from the image file('pixel_valid' = '1') and the FIFO is full
    -- (the signal 'line_1_buff_pfull' is generated at "IMG_WIDTH - 3 - 1"
    -- to anticipate FIFO read latency)
    line_1_buff_rd_en <= '1' when pixel_valid = '1' and line_1_buff_pfull = '1' else '0';
    line_2_buff_rd_en <= '1' when pixel_valid = '1' and line_2_buff_pfull = '1' else '0';

    -- add a signal to tell the PG to wait for FIR to finished
    idx_in_img <= ((y * IMG_WIDTH) + x);
    can_compute <= '1' when idx_in_img >= MIN_IDX_BEFORE_COMP
                            and idx_in_img < MAX_IDX_FOR_COMP else '0';
                            
    cmp_end_frame <= '1' when y = (IMG_HEIGHT + 2 - 1) and x = 2 else '0';
    cmp_end_line <= '1' when x = (IMG_WIDTH - 1) else '0';

    -- set output pixel regs
    p1_reg <= p1_reg_in;
    p2_reg <= p2_reg_in;
    p3_reg <= p3_reg_in;

    p4_reg <= p4_reg_in;
    p5_reg <= p5_reg_in;
    p6_reg <= p6_reg_in;

    p7_reg <= p7_reg_in;
    p8_reg <= p8_reg_in;
    p9_reg <= p9_reg_in;


--    p9_reg <= p9_reg_in when (x+1) < IMG_WIDTH and (y+1) < IMG_HEIGHT and (x+1) >= 0 and (y+1) >= 0 else (others => '0'); -- (x+1, y+1)
--    p8_reg <= p8_reg_in when (x)   < IMG_WIDTH and (y+1) < IMG_HEIGHT and (x)   >= 0 and (y+1) >= 0 else (others => '0'); -- (x, y+1)
--    p7_reg <= p7_reg_in when (x-1) < IMG_WIDTH and (y+1) < IMG_HEIGHT and (x-1) >= 0 and (y+1) >= 0 else (others => '0'); -- (x-1, +y1)
    
--    p6_reg <= p6_reg_in when (x+1) < IMG_WIDTH and (y) < IMG_HEIGHT and (x+1) > 0 and (y) >= 0 else (others => '0'); -- (x+1,y)
--    p5_reg <= p5_reg_in when (x)   < IMG_WIDTH and (y) < IMG_HEIGHT and (x)   > 0 and (y) >= 0 else (others => '0'); -- (x,y)
--    p4_reg <= p4_reg_in when (x-1) < IMG_WIDTH and (y) < IMG_HEIGHT and (x-1) > 0 and (y) >= 0 else (others => '0'); -- (x-1, y)
    
--    p3_reg <= p3_reg_in when (x+1) < IMG_WIDTH and (y-1) < IMG_HEIGHT and (x+1) >= 0 and (y-1) >= 0 else (others => '0'); -- (x+1, y-1)
--    p2_reg <= p2_reg_in when (x)   < IMG_WIDTH and (y-1) < IMG_HEIGHT and (x)   >= 0 and (y-1) >= 0 else (others => '0'); -- (x, y-1)
--    p1_reg <= p1_reg_in when (x-1) < IMG_WIDTH and (y-1) < IMG_HEIGHT and (x-1) >= 0 and (y-1) >= 0 else (others => '0'); -- (x-1, y-1)


    -- use this in the sobel calculation module
--    -- check if the conv kernel is in the image
--    p9_calc <= p9_reg when (x+1) < 640 and (y+1) < 480 and (x+1) >= 0 and (y+1) >= 0 else (others => '0'); -- (x+1, y+1)
--    p8_calc <= p8_reg when (x)   < 640 and (y+1) < 480 and (x)   >= 0 and (y+1) >= 0 else (others => '0'); -- (x, y+1)
--    p7_calc <= p7_reg when (x-1) < 640 and (y+1) < 480 and (x-1) >= 0 and (y+1) >= 0 else (others => '0'); -- (x-1, +y1)
    
--    p6_calc <= p6_reg when (x+1) < 640 and (y) < 480 and (x+1) > 0 and (y) >= 0 else (others => '0'); -- (x+1,y)
--    p5_calc <= p5_reg when (x)   < 640 and (y) < 480 and (x)   > 0 and (y) >= 0 else (others => '0'); -- (x,y)
--    p4_calc <= p4_reg when (x-1) < 640 and (y) < 480 and (x-1) > 0 and (y) >= 0 else (others => '0'); -- (x-1, y)
    
--    p3_calc <= p3_reg when (x+1) < 640 and (y-1) < 480 and (x+1) >= 0 and (y-1) >= 0 else (others => '0'); -- (x+1, y-1)
--    p2_calc <= p2_reg when (x)   < 640 and (y-1) < 480 and (x)   >= 0 and (y-1) >= 0 else (others => '0'); -- (x, y-1)
--    p1_calc <= p1_reg when (x-1) < 640 and (y-1) < 480 and (x-1) >= 0 and (y-1) >= 0 else (others => '0'); -- (x-1, y-1)


end behavioral;