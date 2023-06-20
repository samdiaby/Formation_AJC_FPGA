----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 20.06.2023 15:03:44
-- Design Name: 
-- Module Name: tb_Top - Behavioral
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

entity tb_Top is
--  Port ( );
end tb_Top;

architecture Behavioral of tb_Top is

    signal hpA      : time := 5ns;
    signal periodA  : time := 2*hpA;
    
    signal hpB      : time := 10ns;
    signal periodB  : time := 2*hpB;
    

    signal clk      : std_logic := '0';
    signal resetn   : std_logic := '0';
    signal led0     : std_logic_vector(2 downto 0) := (others => '0');
    signal led1     : std_logic_vector(2 downto 0) := (others => '0');
    
    component Top is
        port (
            -- inputs
            clk 		    : in std_logic;
            resetn		    : in std_logic;
            -- outputs
            led0		    : out std_logic_vector;
            led1		    : out std_logic_vector
        );
    end component;

begin

    uut : Top
    port map (
        -- inputs
        clk => clk,
        resetn => resetn,
        -- outputs
        led0 => led0,
        led1 => led1
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

        resetn <= '1';
        wait for 5*periodA;
        resetn <= '0';

        wait;
    end process;

end Behavioral;
