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

entity tb_pattern_generator is
--  Port ( );
end tb_pattern_generator;

architecture Behavioral of tb_pattern_generator is

    signal hpA      : time := 5ns;
    signal periodA  : time := 2*hpA;
    
    signal hpB      : time := 10ns;
    signal periodB  : time := 2*hpB;
    

    signal clk          : std_logic := '0';
    signal reset        : std_logic := '0';

    signal gen_pixel    : std_logic_vector(11 downto 0);
    
    component pattern_generator is
        port (
            -- inputs
            clk                 : in std_logic;
            reset               : in std_logic;
            --VGA_VSYNC           : in std_logic_vector(11 downto 0);
            
            -- outputs
            -- signals handling color intensity
            gen_pixel             : out std_logic_vector(11 downto 0)
        );
    end component;

begin

    uut : pattern_generator
    port map (
        -- inputs
        clk => clk,
        reset => reset,
        -- outputs
        --requested_pixel => requested_pixel,
        gen_pixel => gen_pixel
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
