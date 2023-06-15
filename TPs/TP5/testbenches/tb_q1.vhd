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
use ieee.numeric_std.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tb_q1 is
--  Port ( );
end tb_q1;


architecture Behavioral of tb_q1 is

    signal hp : time := 5ns;
    signal period : time := 2*hp;

    signal clk      : std_logic := '0';
    signal resetn   : std_logic := '0';
    signal led0     : std_logic_vector(2 downto 0) := (others => '0');
    signal led1     : std_logic_vector(2 downto 0) := (others => '0');

    constant counter_unit_limit : unsigned := to_unsigned(3, 28);

    component q1 is
        generic(
            limit : unsigned(27 downto 0) := counter_unit_limit
        );
        port (
            -- inputs
            clk			    : in std_logic;
            resetn		    : in std_logic;
            -- outputs
            led0            : out std_logic_vector(2 downto 0);
            led1            : out std_logic_vector(2 downto 0)
        );
    end component;

begin

    uut : q1
    generic map (
        limit => counter_unit_limit
    )
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
        wait for hp;
        clk <= not clk;
    end process;


    process
    begin

        resetn <= '1';
        wait for 5*period;
        resetn <= '0';

        wait;
    end process;

end Behavioral;
