----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 20.06.2023 12:19:25
-- Design Name: 
-- Module Name: Top - Behavioral
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

entity Top is
    Port (
        -- inputs
        clk 		    : in std_logic;
        resetn		    : in std_logic;
        -- outputs
        led0		    : out std_logic_vector;
        led1		    : out std_logic_vector
    );
end Top;

architecture Behavioral of Top is

    signal clkA         : std_logic;
    signal clkB         : std_logic;
    signal locked       : std_logic;
    signal resetn2      : std_logic;

    

    -- counter_unit declaration
    component q1
        port (
            -- inputs
            clkA			: in std_logic;
            clkB		    : in std_logic;
            resetn		    : in std_logic;
            -- outputs
            led0            : out std_logic_vector(2 downto 0);
            led1            : out std_logic_vector(2 downto 0)
         );
    end component;
    
    component clk_wiz_0 
        port (
            --Clock in ports
            -- Clock out ports
            clk_a       : out std_logic;
            clk_b       : out std_logic;
            -- Status and control signals
            reset       : in std_logic;
            locked      : out std_logic;
            clk_in1     : in std_logic
        );
    end component;

begin

    -- the first 'led_driver' we will use in this entity
    q1_INST : q1
    port map (
        -- inputs
        clkA => clkA,
        clkB => clkB,
        resetn => resetn2,
        -- outputs
        led0 => led0,
        led1 => led1
    );
    
        clk_wiz_INST : clk_wiz_0
    port map (
        -- inputs
        clk_a => clkA,
        clk_b => clkB,
        reset => resetn,
        -- outputs
        locked => locked,
        clk_in1 => clk
    );
    
resetn2 <= '1' when resetn = '1' OR locked = '0' else '0';

end Behavioral;
