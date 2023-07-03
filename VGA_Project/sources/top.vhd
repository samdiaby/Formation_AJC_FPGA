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
      
    -- VGA driver signals
    signal RGB_pixel                : std_logic_vector(11 downto 0); -- FIFO out signal
    
    -- PLL signals
    signal locked                   : std_logic;
    
    -- locked logic
    signal nlocked                  : std_logic;
    
    signal top_is_in_display        : std_logic;
    
    signal clock_out                : std_logic;
    
    component clk_wiz_0 is 
    Port (
        -- input
        reset       : in std_logic;
        clk_in     : in std_logic;

        -- output
        clk_out    : out std_logic;
        locked      : out std_logic
    );
    end component;

    component vga_driver is
    Port (
        -- inputs
        clk                 : in std_logic;
        reset               : in std_logic;
        RGB_pixel           : in std_logic_vector(11 downto 0);

        -- outputs
        -- signals handling color intensity
        int_red             : out std_logic_vector(3 downto 0);
        int_green           : out std_logic_vector(3 downto 0);
        int_blue            : out std_logic_vector(3 downto 0);
        
        is_in_display_out   : out std_logic;
    
        
        -- signals handling frame printing
        --requested_pixel     : out std_logic_vector(11 downto 0); -- get the requested pixel from a frame buffer
        vsync               : out std_logic;
        hsync               : out std_logic
    );
    end component;

    component pattern_generator is
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
    end component;

begin
    -- PLL instance 
    PLL_INST : clk_wiz_0
    port map (
        -- input
        reset => reset,
        clk_in => clk,

        -- output
        clk_out => clock_out,
        locked => locked
    );
    
    PATTERN_GENERATOR_INST : pattern_generator
    port map (
        -- inputs
        clk => clock_out,
        reset => nlocked,
        VGA_is_in_display => top_is_in_display,

        
        -- outputs
        -- signals handling color intensity
        gen_pixel => RGB_pixel
    );

    VGA_DRIVER_INST : vga_driver
    port map (
        -- inputs
        clk => clock_out,
        reset => nlocked,
        RGB_pixel => RGB_pixel,
        
        -- outputs
        -- signals handling color intensity
        int_red => int_red,
        int_green => int_green,
        int_blue => int_blue,
        is_in_display_out => top_is_in_display,
        
        -- signals handling frame printing
        --requested_pixel     : out std_logic_vector(11 downto 0); -- get the requested pixel from a frame buffer
        vsync => vsync,
        hsync => hsync
    );

    --
    nlocked <= not locked;

end Behavioral;
