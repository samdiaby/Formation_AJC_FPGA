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
    
    signal wr_rst_busy              : std_logic;
    signal rd_rst_busy              : std_logic;
    
    signal fifo_full                : std_logic;
    signal fifo_empty               : std_logic;
    
    signal FIFO_wr_en               : std_logic;
    
    -- VGA driver signals
    signal read_pixel               : std_logic;
    signal RGB_pixel                : std_logic_vector(11 downto 0); -- FIFO out signal
    
    -- PLL signals
    signal clkA                     : std_logic;
    signal clkB                     : std_logic;
    signal locked                   : std_logic;
    
    component clk_wiz_0 is 
    Port (
        -- input
        reset       : in std_logic;
        clk_in1     : in std_logic;

        -- output
        clk_out1    : out std_logic;
        clk_out2    : out std_logic;
        locked      : out std_logic
    );
    end component;
    
    component fifo_generator_0 IS
        Port (
            rst : IN STD_LOGIC;
            wr_clk : IN STD_LOGIC;
            rd_clk : IN STD_LOGIC;
            din : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
            wr_en : IN STD_LOGIC;
            rd_en : IN STD_LOGIC;
            dout : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
            full : OUT STD_LOGIC;
            empty : OUT STD_LOGIC;
            wr_rst_busy : OUT STD_LOGIC;
            rd_rst_busy : OUT STD_LOGIC
        );
    END component;
    
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
        
        -- signals handling frame printing
        --requested_pixel     : out std_logic_vector(11 downto 0); -- get the requested pixel from a frame buffer
        read_pixel          : out std_logic;
        vsync               : out std_logic;
        hsync               : out std_logic
    );
    end component;

    component pattern_generator is
    Port (
        -- inputs
        clk                 : in std_logic;
        reset               : in std_logic;
        FIFO_full           : in std_logic;
        --VGA_VSYNC           : in std_logic_vector(11 downto 0);
        
        -- outputs
        -- signals handling color intensity
        gen_pixel             : out std_logic_vector(11 downto 0);
        FIFO_wr_en            : out std_logic
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
        clk_in1 => clk,

        -- output
        clk_out1 => clkA,
        clk_out2 => clkB,
        locked => locked
    );

    -- the 'fifo_generator_0' instance we will use in this entity
    FIFO_ISNT : fifo_generator_0
    port map (
    -- inputs
        wr_clk => clkA,
        rd_clk => clkB,
        rst => reset,
        din => gen_pixel, -- mux output color
        wr_en => FIFO_wr_en,
        rd_en => read_pixel,
    -- outputs
        dout => RGB_pixel,
        full => FIFO_full,
        empty => fifo_empty,
        wr_rst_busy => wr_rst_busy,
        rd_rst_busy => rd_rst_busy
    );
    
    PATTERN_GENERATOR_INST : pattern_generator
    port map (
        -- inputs
        clk => clkA,
        reset => reset,
        FIFO_full => FIFO_full,
        
        -- outputs
        -- signals handling color intensity
        gen_pixel => gen_pixel,
        FIFO_wr_en => FIFO_wr_en
    );

    VGA_DRIVER_INST : vga_driver
    port map (
        -- inputs
        clk => clkB,
        reset => reset,
        RGB_pixel => RGB_pixel,
        
        -- outputs
        -- signals handling color intensity
        int_red => int_red,
        int_green => int_green,
        int_blue => int_blue,
        
        -- signals handling frame printing
        --requested_pixel     : out std_logic_vector(11 downto 0); -- get the requested pixel from a frame buffer
        read_pixel => read_pixel,
        vsync => vsync,
        hsync => hsync
    );


end Behavioral;
