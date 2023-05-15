library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_tp_fsm is
end tb_tp_fsm;

architecture behavioral of tb_tp_fsm is

    -- input signals for 'tp_fsm'
	signal resetn          : std_logic := '0';
	signal clk             : std_logic := '0';
	signal restart         : std_logic := '0';

	-- output signals for 'tp_fsm' (rgb led)
	signal led0_b          : std_logic := '0';
    signal led0_g          : std_logic := '0';
    signal led0_r          : std_logic := '0';
    
    signal led1_b          : std_logic := '0';
    signal led1_g          : std_logic := '0';
    signal led1_r          : std_logic := '0';
    

	-- constants for 'tp_fsm'

    -- cu_cnt_limit -> counter_unit_count_limit
	-- will be used to determine the count limit for 1 'half on/off cycle' for the leds
	constant cu_cnt_limit  : unsigned := to_unsigned(4, 28);

    -- arrays for states checking
    type state is (White_led, Red_led, Blue_led, Green_led);
    -- tb internal signals for 'tp_fsm'
    signal tb_curr_state : state;

	-- Les constantes suivantes permette de definir la frequence de l'horloge
	constant hp        : time := 5 ns;  --demi periode de 5ns
	constant period    : time := 2*hp;  --periode de 10ns, soit une frequence de 100Hz


	component tp_fsm
	   generic(
	       limit : unsigned(27 downto 0)
	   );
		port (
			clk			    : in std_logic;
			resetn		    : in std_logic;
			restart         : in std_logic;
			-- LED 0
            led0_b          : out std_logic;
            led0_g          : out std_logic;
            led0_r          : out std_logic;
            -- LED1
            led1_b          : out std_logic;
            led1_g          : out std_logic;
            led1_r          : out std_logic
        );
	end component;


	begin
	dut: tp_fsm
	    generic map (
	       limit => cu_cnt_limit
	    )
        port map (
            clk => clk, 
            resetn => resetn,
			restart => restart,
			led0_b => led0_b,
			led0_g => led0_g,
			led0_r => led0_r,
			led1_b => led1_b,
			led1_g => led1_g,
			led1_r => led1_r
        );
		
	--Simulation du signal d'horloge en continue
	process
    begin
		wait for hp;
		clk <= not clk;
	end process;


    -- this process will be used to change the state of the fsm in the tb
    -- in order to test the output of the rgb leds
    -- (we can't access the state directly from the tb)
    p_change_state : process
        variable resetn_period  : time := 5 * period;
        variable iecc_period    : time := to_integer(cu_cnt_limit + 1) * period; -- period for a half on/off cycle (only 'on' or 'off')
        variable state_period    : time := 6 * iecc_period; -- wait for 3 on/off cylces
    begin

        wait for resetn_period; -- wait for the initial resetn period
        
        l_tb_change_state : loop
            wait for state_period;
        
            -- change the state after 3 on/off cycles
            case tb_curr_state is 
                when White_led =>
                    tb_curr_state <= Red_led;
                   
               when Red_led =>
                    tb_curr_state <= Blue_led;
                    
               when Blue_led =>
                    tb_curr_state <= Green_led;
                    
               when Green_led =>
                    tb_curr_state <= White_led;
            end case;
        end loop l_tb_change_state;
    end process p_change_state;


	process
	   -- initial resetn period
	   variable resetn_period  : time := 5 * period;
	   -- period to wait before the iecc counter is incremented by 1
	   variable iecc_period    : time := to_integer(cu_cnt_limit + 1) * period;
	begin

		resetn <= '1';
		wait for resetn_period;    
		resetn <= '0';
	   
	    -- tests for 'tp_fsm" begin here
		l_fsm_tb : loop
		    -- set the 'current_state' according to tb time
		    if (now / (iecc_period * 6)) = 0 then
		    end if;
		
		    -- test the current state
		    case tb_curr_state is
                when White_led =>
                    assert ((led0_r = '0' and led0_b = '0' and led0_g = '0') -- led_state = '0' / off
                            or (led0_r = '1' and led0_b = '1' and led0_g = '1')) -- led_state = '1' / on
                            and ((led1_r = '0' and led1_b = '0' and led1_g = '0')
                            or (led1_r = '1' and led1_b = '1' and led1_g = '1'))
                    report "Error : FSM state is 'White led' and one of the led channel is not 'on'"
                    severity failure;
                
                when Red_led =>
                    assert ((led0_r = '0' and led0_b = '0' and led0_g = '0') -- led_state = '0' / off
                            or (led0_r = '1' and led0_b = '0' and led0_g = '0')) -- led_state = '1' / on
                            and ((led1_r = '0' and led1_b = '0' and led1_g = '0')
                            or (led1_r = '1' and led1_b = '0' and led1_g = '0'))
                    report "Error : FSM state is 'Red led' and the led behaviour isn't correct"
                    severity failure;

                when Blue_led =>
                    assert ((led0_r = '0' and led0_b = '0' and led0_g = '0') -- led_state = '0' / off
                            or (led0_r = '0' and led0_b = '1' and led0_g = '0')) -- led_state = '1' / on
                            and ((led1_r = '0' and led1_b = '0' and led1_g = '0')
                            or (led1_r = '0' and led1_b = '1' and led1_g = '0'))
                    report "Error : FSM state is 'Blue led' and the led behaviour isn't correct"
                    severity failure;

                when Green_led =>
                    assert ((led0_r = '0' and led0_b = '0' and led0_g = '0') -- led_state = '0' / off
                            or (led0_r = '0' and led0_b = '0' and led0_g = '1')) -- led_state = '1' / on
                            and ((led1_r = '0' and led1_b = '0' and led1_g = '0')
                            or (led1_r = '0' and led1_b = '0' and led1_g = '1'))
                    report "Error : FSM state is 'Green led' and the led behaviour isn't correct"
                    severity failure;
		    end case;
		    
		    -- wait until 'next state' set 'current_state'
		    wait for iecc_period;
		    
		end loop l_fsm_tb;
	   
	   
		wait;
	    
	end process;
	
	
end behavioral;