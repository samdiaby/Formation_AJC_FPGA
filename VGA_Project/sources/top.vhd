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

entity top is
    Port (
        -- inputs
        clk                 : in std_logic;
        reset               : in std_logic;
        
        -- outputs
        -- signals handling color intensity
        int_red             : out std_logic_vector(3 downto 0);
        int_green           : out std_logic_vector(3 downto 0);
        int_blue            : out std_logic_vector(3 downto 0);
        
        -- signals handling frame printing
        vsync               : out std_logic;
        hsync               : out std_logic
    );
end top;

architecture Behavioral of top is

    signal gen_pixel                : std_logic_vector(11 downto 0);
    signal can_start_printing       : std_logic;
    signal can_filter       : std_logic;


    -- VGA driver signals
    signal is_in_display            : std_logic;
    signal RGB_pixel                : std_logic_vector(11 downto 0); -- FIFO out signal


    signal start_gen_next_frame     : std_logic;
    signal x : unsigned(9 downto 0);
    signal y : unsigned(9 downto 0);

    -- PLL signals
    signal clk_25_2Mhz              : std_logic;
    signal locked                   : std_logic;

    -- FIR signals
    signal FIR_requested_pixel      : std_logic_vector(11 downto 0);
    
    signal FIR_red_out              : std_logic_vector(3 downto 0);
    signal FIR_green_out            : std_logic_vector(3 downto 0);
    signal FIR_blue_out             : std_logic_vector(3 downto 0);
    
    signal wait_fir_red             : std_logic;
    signal wait_fir_blue            : std_logic;
    signal wait_fir_green           : std_logic;
    
    signal fir_col_delay            : unsigned(9 downto 0);
    signal fir_row_delay            : unsigned(9 downto 0);
    
    signal fir_col_delay_g          : unsigned(9 downto 0);
    signal fir_row_delay_g          : unsigned(9 downto 0);
    
    signal fir_col_delay_b          : unsigned(9 downto 0);
    signal fir_row_delay_b          : unsigned(9 downto 0);


    -- locked logic

    signal nlocked                  : std_logic;

    component clk_wiz_0 is 
    Port (
        -- input
        reset           : in std_logic;
        clk_in1         : in std_logic; -- 125MHz

        -- output
        clk_25_2Mhz     : out std_logic; --50.4MHz
        locked          : out std_logic
    );
    end component;
    
    component vga_driver is
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
    end component;

    component pattern_generator_FIR is
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
    end component;

    component FIR is
    Port (
          clk               : in std_logic;
          reset             : in std_logic;

          -- signals from Pattern generator
          last_gen_pixel    : in std_logic_vector(3 downto 0);
          can_filter        : in std_logic;
          
          -- signals from VGA_driver
          x                 : in unsigned(9 downto 0);
          y                 : in unsigned(9 downto 0);

          FIR_pix           : out std_logic_vector(3 downto 0);
          wait_fir          : out std_logic
    );
    end component;

begin
    -- PLL instance 
    PLL_INST : clk_wiz_0
    port map (
        -- input
        reset => reset,
        clk_in1 => clk,

        -- output
        clk_25_2Mhz => clk_25_2Mhz,
        locked => locked
    );

    FIR_RED : FIR
    port map (
        clk => clk_25_2Mhz,
        reset => nlocked,
        last_gen_pixel => FIR_requested_pixel(11 downto 8),
        can_filter => can_filter,
        x => x,
        y => y,

        FIR_pix => FIR_red_out,
        wait_fir => wait_fir_red
    );

    FIR_GREEN : FIR
    port map (
        clk => clk_25_2Mhz,
        reset => nlocked,
        last_gen_pixel => FIR_requested_pixel(7 downto 4),
        can_filter => can_filter,
        x => x,
        y => y,

        FIR_pix => FIR_green_out
    );

    FIR_BLUE : FIR
    port map (
        clk => clk_25_2Mhz,
        reset => nlocked,
        last_gen_pixel => FIR_requested_pixel(3 downto 0),
        can_filter => can_filter,
        x => x,
        y => y,

        FIR_pix => FIR_blue_out
    );

    PATTERN_GENERATOR_FIR_INST : pattern_generator_FIR
    port map (
        -- inputs
        clk => clk_25_2Mhz,
        reset => nlocked,
        VGA_is_in_display => is_in_display,
        start_gen_next_frame => start_gen_next_frame,
        wait_fir => wait_fir_red,
        -- outputs
        -- signals handling color intensity
        gen_pixel => FIR_requested_pixel,

        -- outputs
        -- signals handling color intensity
        can_start_printing => can_start_printing,
        can_filter => can_filter
    );

    RGB_pixel <= FIR_red_out & FIR_green_out & FIR_blue_out;

    VGA_DRIVER_INST : vga_driver
    port map (
        -- inputs
        clk => clk_25_2Mhz,
        reset => nlocked,
        RGB_pixel => RGB_pixel,
        can_start_printing => can_start_printing,

        -- outputs
        -- signals handling color intensity
        int_red => int_red,
        int_green => int_green,
        int_blue => int_blue,

        -- signals handling frame printing
        vsync => vsync,
        hsync => hsync,

        is_in_display => is_in_display,
        start_gen_next_frame => start_gen_next_frame,

        x => x,
        y => y
    );

    -- combinatory logic
    nlocked <= not locked;

end Behavioral;
