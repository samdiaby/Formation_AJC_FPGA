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

entity sobel_y is
    Port (
        -- inputs
        p1_reg   : in std_logic_vector(7 downto 0);
        p2_reg   : in std_logic_vector(7 downto 0);
        p3_reg   : in std_logic_vector(7 downto 0);
        p4_reg   : in std_logic_vector(7 downto 0) := (others => '0');
        p5_reg   : in std_logic_vector(7 downto 0) := (others => '0');
        p6_reg   : in std_logic_vector(7 downto 0) := (others => '0');
        p7_reg   : in std_logic_vector(7 downto 0);
        p8_reg   : in std_logic_vector(7 downto 0);
        p9_reg   : in std_logic_vector(7 downto 0);
                
        -- outputs
        out_y    : out std_logic_vector(10 downto 0)
    );
end sobel_y;

architecture Behavioral of sobel_y is

    -- intern signals
    
        signal p1_out   : unsigned(7 downto 0);
        signal p2_out   : unsigned(7 downto 0);
        signal p3_out   : unsigned(7 downto 0);
        signal p7_out   : unsigned(7 downto 0);
        signal p8_out   : unsigned(7 downto 0);
        signal p9_out   : unsigned(7 downto 0);
    

begin

    -- combinatory logic
    
    p1_out <= unsigned(p1_reg);
    p2_out <= shift_left(unsigned(p2_reg), 1);
    p3_out <= unsigned(p3_reg);
    p7_out <= NOT unsigned(p7_reg);
    p8_out <= NOT shift_left(unsigned(p8_reg), 1);
    p9_out <= NOT unsigned(p9_reg);
    
    
    out_y <= std_logic_vector(p1_out + p2_out + p3_out + p7_out + p8_out + p9_out); 
        

end Behavioral;
