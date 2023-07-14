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
        out_y    : out integer
    );
end sobel_y;

architecture Behavioral of sobel_y is

    -- intern signals

        signal p1_out   : integer;
        signal p2_out   : integer;
        signal p3_out   : integer;
        signal p7_out   : integer;
        signal p8_out   : integer;
        signal p9_out   : integer;

        signal out_y_in : integer;
begin

    -- combinatory logic

    p1_out <= to_integer(unsigned(p1_reg));
    p2_out <= to_integer(unsigned(p2_reg)) * (2);
    p3_out <= to_integer(unsigned(p3_reg));
    p7_out <= to_integer(unsigned(p7_reg)) * (-1);
    p8_out <= to_integer(unsigned(p8_reg)) * (-2);
    p9_out <= to_integer(unsigned(p9_reg)) * (-1);

    out_y_in <= p1_out + p2_out + p3_out + p7_out + p8_out + p9_out;
    out_y <= out_y_in when out_y_in > 0 else out_y_in * (-1);
--    out_y <= out_y_in;
        

end Behavioral;
