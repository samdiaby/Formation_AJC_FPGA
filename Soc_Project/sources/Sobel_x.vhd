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
        out_x    : out integer
    );
end sobel_x;

architecture Behavioral of sobel_x is

    -- intern signals

        signal p1_out   : integer;
        signal p3_out   : integer;
        signal p4_out   : integer;
        signal p6_out   : integer;
        signal p7_out   : integer;
        signal p9_out   : integer;
    
        signal out_x_in : integer;
begin

    -- combinatory logic
    
    p1_out <= to_integer(signed(p1_reg)) * (-1);
    p3_out <= to_integer(signed(p3_reg));
    p4_out <= to_integer(signed(p4_reg)) * (-2);
    p6_out <= to_integer(signed(p6_reg)) * (2);
    p7_out <= to_integer(signed(p7_reg))  * (-1);
    p9_out <= to_integer(signed(p9_reg));
    
    out_x_in <= p1_out + p3_out + p4_out + p6_out + p7_out + p9_out;
    out_x <= out_x_in, 11;
        

end Behavioral;
