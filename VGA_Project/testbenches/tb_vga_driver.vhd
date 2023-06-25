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

entity tb_vga_driver is
--  Port ( );
end tb_vga_driver;

architecture Behavioral of tb_vga_driver is

    signal hpA      : time := 5ns;
    signal periodA  : time := 2*hpA;
    
    signal hpB      : time := 10ns;
    signal periodB  : time := 2*hpB;
    

    signal clk          : std_logic := '0';
    signal reset        : std_logic := '0';
    signal RGB_pixel    : std_logic_vector(11 downto 0);
    
    signal int_red      : std_logic_vector(3 downto 0);
    signal int_green    : std_logic_vector(3 downto 0);
    signal int_blue     : std_logic_vector(3 downto 0);

    signal requested_pixel  : std_logic_vector(11 downto 0);
    signal read_pixel       : std_logic;
    signal vsync            : std_logic;
    signal hsync            : std_logic;
    
    component vga_driver is
        port (
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

begin

    uut : vga_driver
    port map (
        -- inputs
        clk => clk,
        reset => reset,
        RGB_pixel => RGB_pixel,
        -- outputs
        int_red => int_red,
        int_green => int_green,
        int_blue => int_blue,
    
        --requested_pixel => requested_pixel,
        read_pixel => read_pixel,
        vsync =>vsync,
        hsync => hsync
    );

    process
    begin
        wait for hpA;
        clk <= not clk;
    end process;
    
--        process
--    begin
--        wait for hpB;
--        clkB <= not clkB;
--    end process;

    process
    begin

        reset <= '1';
        wait for 5*periodA;
        reset <= '0';

        wait;
    end process;

end Behavioral;
