library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity led_blinker is
    generic(
        limit : unsigned(27 downto 0) := to_unsigned(100_000_000, 28) -- generic param for counter_unit
    );
    port ( 
		clk			    : in std_logic;
        resetn		    : in std_logic;
        btn0		    : in std_logic;
        led0_r          : out std_logic;
        led0_g          : out std_logic
     );
end led_blinker;

architecture behavioral of led_blinker is

    --    type state is (idle, state1, state2); --a modifier avec vos etats
    type state is (Led_off, Led_on); --a modifier avec vos etats
    
    signal current_state    : state;  --etat dans lequel on se trouve actuellement
    signal next_state       : state;	   --etat dans lequel on passera au prochain coup d'horloge

    -- demux command signal
    signal demux_cmd        : std_logic;
    -- Q6 : add internal signal to handle 1 green led
    -- blinking when pressing btn0
    signal is_btn_pressed   : std_logic;
    signal green_led_cond   : std_logic;


    -- led signals
    signal intern_end_counter   : std_logic;
    signal led_state            : std_logic;

    -- counter_unit declaration
	component counter_unit
	   generic(
	       limit : unsigned(27 downto 0) := limit
	   );
	   port (
	       clk          : in std_logic; 
	       resetn       : in std_logic;
	       end_counter	 : out std_logic
		 );
	end component;

begin

    -- the 'counter_unit' we will use in this entity
    LED_COUNTER : counter_unit
    generic map (
       limit => limit -- set this value to change the time between LED blinks
    )
    port map (
        clk => clk,
        resetn => resetn,
        end_counter => intern_end_counter
    );

    -- handle the FSM current state
    process(clk, resetn)
    begin
        if (resetn = '1') then
            current_state <= Led_off;
            
            -- Q6 : reset registers
            is_btn_pressed <= '0';
            green_led_cond <= '0';
        elsif (rising_edge(clk)) then
            current_state <= next_state;
            
            -- Q6 : set regsiters
            is_btn_pressed <= btn0;
            green_led_cond <= btn0 and (not is_btn_pressed);

        end if;
    end process;

    -- combinatory logic
    -- demux logic

    -- set demux command according to the input btn
    --demux_cmd <= btn0;
    demux_cmd <= green_led_cond; -- Q6
    

    -- red led blinks only if btn0 is released
    led0_r <= led_state when demux_cmd = '0' else '0';
    -- green led blinks only if btn0 is pressed
    led0_g <= led_state when demux_cmd = '1' else '0';



    -- FSM
    -- we'll use 1 process for the 2 FSMs (1 for each led)
    process(current_state, intern_end_counter)
    begin

        -- next_state is set to current state as default
        next_state <= current_state;

        case current_state is
            when Led_off =>
                -- change FSM state
                if intern_end_counter = '1' then
                    next_state <= Led_on;
                end if;

                -- execute state logic
                led_state <= '0';

            when Led_on =>
                -- change FSM 
                if intern_end_counter = '1' then
                    next_state <= Led_off;
                end if;

                -- execute state logic
                led_state <= '1';
        end case; 
    end process;

end behavioral;