----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01.06.2023 17:36:40
-- Design Name: 
-- Module Name: test_PLL - Behavioral
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

entity test_PLL is
    Port ( clk : in STD_LOGIC;
           resetn : in STD_LOGIC;
            clk_a : out STD_LOGIC;
            clk_b : out STD_LOGIC
          );
end test_PLL;


architecture Behavioral of test_PLL is

    signal reset    : std_logic;
--    signal intern_clk_a    : std_logic;
--    signal intern_clk_b    : std_logic;
    signal locked    : std_logic;
    
    component clk_wiz_0 is
        port(
            clk_in1 :   in std_logic;
            reset   :   in std_logic;
            clk_a   :   out std_logic;
            clk_b   :   out std_logic;
            locked  :   out std_logic
        );
    end component;

begin

    -- set reset from resetn
    reset <= not resetn;

    -- instanciate the PLL comp
    PLL_inst : clk_wiz_0
        port map(
            clk_in1 => clk,
            reset => reset,
            clk_a => clk_a,
            clk_b => clk_b,
            locked => locked
        );


end Behavioral;
