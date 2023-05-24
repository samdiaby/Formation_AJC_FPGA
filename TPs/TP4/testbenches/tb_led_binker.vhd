library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_led_blinker is
end tb_led_blinker;

architecture behavioral of tb_led_blinker is

    -- input signals for 'tp_fsm'
	signal resetn          : std_logic := '0';
	signal clk             : std_logic := '0';
	signal btn0            : std_logic := '0';

	-- output signals for 'tp_fsm' (rgb led)
    signal led0_g          : std_logic := '0';
    signal led0_r          : std_logic := '0';

	-- constants for 'tp_fsm'

    -- cu_cnt_limit -> counter_unit_count_limit
	-- will be used to determine the count limit for 1 'half on/off cycle' for the leds
	constant cu_cnt_limit  : unsigned := to_unsigned(4, 28);

    -- arrays for states checking
    type state is (Led_on, Led_off);
    -- tb internal signals for 'tp_fsm'
    signal tb_curr_state : state;

	-- Les constantes suivantes permette de definir la frequence de l'horloge
	constant hp        : time := 5 ns;  --demi periode de 5ns
	constant period    : time := 2*hp;  --periode de 10ns, soit une frequence de 100Hz


	component led_blinker
	   generic(
	       limit : unsigned(27 downto 0)
	   );
		port (
			clk              : in std_logic;
			resetn		     : in std_logic;
			btn0             : in std_logic;
			-- LED 0
            led0_g          : out std_logic;
            led0_r          : out std_logic
        );
	end component;

	begin
	dut: led_blinker
	    generic map (
	       limit => cu_cnt_limit
	    )
        port map (
            clk => clk, 
            resetn => resetn,
			btn0 => btn0,
			led0_g => led0_g,
			led0_r => led0_r
        );
		
	--Simulation du signal d'horloge en continue
	process
    begin
		wait for hp;
		clk <= not clk;
	end process;


	process
	   -- initial resetn period
	   variable resetn_period  : time := 5 * period;
	   -- period to wait before the iecc counter is incremented by 1
	   variable iecc_period    : time := to_integer(cu_cnt_limit + 1) * period;
	begin

		resetn <= '1';
		wait for resetn_period;    
		resetn <= '0';
	   
	   wait for iecc_period;
	   
	   btn0 <= '1';
	   wait for  iecc_period / 2;
	   btn0 <= '0';
	   
		wait;
	    
	end process;
	
	
end behavioral;