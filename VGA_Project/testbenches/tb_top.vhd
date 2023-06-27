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

entity tb_top is
--  Port ( );
end tb_top;

architecture Behavioral of tb_top is

    signal hp      : time := 4ns; -- 125MHz
    signal period  : time := 2*hp;
    
    signal hpA      : time := 10ns; -- 125MHz
    signal periodA  : time := 2*hpA;
    

    signal clk          : std_logic := '0';
    signal reset        : std_logic := '0';

    signal int_red      : std_logic_vector(3 downto 0);
    signal int_green    : std_logic_vector(3 downto 0);
    signal int_blue     : std_logic_vector(3 downto 0);
    
    signal vsync   : std_logic;
    signal hsync   : std_logic;
    
    component top is
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
    end component;

begin

    uut : top
    port map (
        -- inputs
        clk => clk,
        reset => reset,
        int_red => int_red,
        int_green => int_green,
        int_blue => int_blue,
        -- outputs
        --requested_pixel => requested_pixel,
        vsync => vsync,
        hsync => hsync
    );

    process
    begin
        wait for hp;
        clk <= not clk;
    end process;

    process
    begin
        reset <= '1';
        wait for 3*periodA;
        reset <= '0';

        wait;
    end process;

end Behavioral;
