library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity tb_counter is
end tb_counter;

architecture behavioral of tb_counter is

	signal resetn      : std_logic := '0';
	signal clk         : std_logic := '0';
	signal end_counter : std_logic := '0';
	
	-- Les constantes suivantes permette de definir la frequence de l'horloge 
	constant hp : time := 5 ns;      --demi periode de 5ns
	constant period : time := 2*hp;  --periode de 10ns, soit une frequence de 100Hz
	
	--Declaration de l'entite a tester
	component counter_unit
	   generic(
	       limit : unsigned(27 downto 0)
	   );
	   port (
	       clk          : in std_logic; 
	       resetn       : in std_logic;
	       end_counter	 : out std_logic
		 );
	end component;
	
	begin
	
	--Affectation des signaux du testbench avec ceux de l'entite a tester
	uut: counter_unit
	generic map (
	   limit => to_unsigned(5, 28)
	)
    port map (
        clk => clk,
        resetn => resetn,
        end_counter => end_counter
    );

	--Simulation du signal d'horloge en continue
	process
    begin
		wait for hp;
		clk <= not clk;
	end process;


	-- restart signal simulation (Q12)
	process
    begin
		wait for 150 ns;
		resetn <= not resetn;
	end process;
	
	-- resetn signal simulation (Q6)
--	process
--    begin
--		wait for 60 ns;
--		resetn <= not resetn;
--	end process;

	process
	   constant first_period   : time := 10ns;
	   variable cnt_period     : time := first_period;
	   variable led_state      : std_logic := '1';
	begin        
	   
	   -- TESTS A EFFECTUER

	   wait for cnt_period;
	   
	   -- should be triggered at 200ns
--	   assert end_counter = led_state
--	       report "Q6 test failed : 'end_counter' is supposed to be 1 when 'cnt' is equal to '4'"
--	       severity failure;
	       
	   -- set the 'led_state' test variable according to
	   -- the value it's supposed to be
	   led_state := not led_state;
	       
	end process;
	
	
end behavioral;