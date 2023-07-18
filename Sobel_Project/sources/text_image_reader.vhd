library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity text_image_reader is
	generic(
		PX_SIZE : integer := 8        -- taille d'un pixel
	);
	port(
		resetn	: in std_logic;
		clk		: in std_logic;
		input_data	        : in std_logic_vector(PX_SIZE-1 downto 0);
		input_data_valid	: in std_logic;
		output_data	        : out std_logic_vector(PX_SIZE-1 downto 0);
		output_data_valid	: out std_logic
	);
end text_image_reader;


architecture rtl of text_image_reader is

begin

	process(clk, resetn)
	begin
		if(resetn='1') then
			output_data <= (others => '0');
			output_data_valid <= '0';
		elsif(rising_edge(clk)) then 
		    if(input_data_valid = '1') then
			   output_data <= input_data;
			   output_data_valid <= '1';
			end if;
		end if;
	end process;

end architecture;