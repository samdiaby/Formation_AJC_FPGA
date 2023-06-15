----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02.06.2023 10:09:21
-- Design Name: 
-- Module Name: tb_test_PLL - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tb_test_PLL is
--  Port ( );
end tb_test_PLL;


architecture Behavioral of tb_test_PLL is

    signal hp : time := 5ns;
    signal period : time := 2*hp;

    signal clk      : std_logic := '0';
    signal clk_a    : std_logic := '0';
    signal clk_b    : std_logic := '0';
    signal resetn   : std_logic := '0';


    component test_PLL is
        Port ( clk : in STD_LOGIC;
           resetn : in STD_LOGIC;
            clk_a : out STD_LOGIC;
            clk_b : out STD_LOGIC
          );
    end component;

begin

    process
    begin
        wait for hp;
        clk <= not clk;
    end process;


    uut : test_PLL
    port map (
        clk => clk,
        resetn => resetn,
        clk_a => clk_a,
        clk_b => clk_b
    );


    process
    begin

        resetn <= '0';
        wait for period;
        resetn <= '1';

        wait;
    end process;

end Behavioral;
