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

entity sobel_x is
    Port (
        -- inputs
        p1_reg   : in std_logic_vector(7 downto 0);
        p2_reg   : in std_logic_vector(7 downto 0) := (others => '0');
        p3_reg   : in std_logic_vector(7 downto 0);
        p4_reg   : in std_logic_vector(7 downto 0);
        p5_reg   : in std_logic_vector(7 downto 0) := (others => '0');
        p6_reg   : in std_logic_vector(7 downto 0);
        p7_reg   : in std_logic_vector(7 downto 0);
        p8_reg   : in std_logic_vector(7 downto 0) := (others => '0');
        p9_reg   : in std_logic_vector(7 downto 0);
                
        -- outputs
        out_x    : out std_logic_vector(10 downto 0)
    );
end sobel_x;

architecture Behavioral of sobel_x is

    -- intern signals

        signal p1_out   : signed(8 downto 0);
        signal p3_out   : signed(8 downto 0);
        signal p4_out   : signed(8 downto 0);
        signal p6_out   : signed(8 downto 0);
        signal p7_out   : signed(8 downto 0);
        signal p9_out   : signed(8 downto 0);
    

begin

    -- combinatory logic
    
    p1_out <= signed("0" & p1_reg);
    p3_out <= NOT signed("0" & p3_reg);
    p4_out <= shift_left(signed("0" & p4_reg), 1);
    p6_out <= NOT shift_left(signed("0" & p6_reg), 1);
    p7_out <= signed("0" & p7_reg);
    p9_out <= NOT signed("0" & p9_reg);
    
    
    out_x <= std_logic_vector(p1_out + p3_out + p4_out + p6_out + p7_out + p9_out); 
        

end Behavioral;
