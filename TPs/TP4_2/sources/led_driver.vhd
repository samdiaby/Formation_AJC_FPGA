library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity led_driver is
    generic(
        limit : unsigned(27 downto 0) := to_unsigned(99_999_999, 28) -- generic param for counter_unit
    );
    port (
        -- inputs
		clk			    : in std_logic;
        resetn		    : in std_logic;
        color_code      : in std_logic_vector(1 downto 0);
        update		    : in std_logic;
        -- outputs
        led0_r          : out std_logic;
        led0_g          : out std_logic;
        led0_b          : out std_logic;
        end_cycle       : out std_logic
     );
end led_driver;

architecture behavioral of led_driver is

    -- FSM states declaration
    type state is (Led_off, Led_on);
    
    signal current_state    : state;  --etat dans lequel on se trouve actuellement
    signal next_state       : state;  --etat dans lequel on passera au prochain coup d'horloge

    -- led_driver demux command signal
    signal led_state            : std_logic := '0';
    signal current_color_code   : std_logic_vector(1 downto 0) := (others => '0');

    -- led signals
    signal intern_end_counter   : std_logic := '0';
    
    -- cycle counter logic
    -- constant to limit the number of cycles to count
    -- 1 cycle = 2 counts of "end_counter"
    constant led_cycle_cnt_limit    : unsigned := to_unsigned(2, 2);
    
    -- internal signal for the cycle counter
    signal led_cycle_cnt            : unsigned(1 downto 0) := (others => '0');

    -- result of the comparison of 'led_cycle_cnt' and 'led_cycle_cnt_limit'
    signal cmp_led_cycle_cnt        : std_logic := '0';

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
    process(clk, resetn)--, update)
    begin
        if (resetn = '1') then
            current_state <= Led_off;

            -- reset demux cmd signal register
            -- (used to keep the previously selected color
            -- as the current color)
            current_color_code <= (others => '0');

            -- reset led cycles counter register
            led_cycle_cnt <= (others => '0');

        elsif (rising_edge(clk)) then
            current_state <= next_state;
            
            -- set demux cmd signal (current_color_code)
            -- according to the update button
            if (update = '1') then
                current_color_code <= color_code;
            else
                current_color_code <= current_color_code;
            end if;

            -- led cycle counter logic
            if (cmp_led_cycle_cnt = '0') then
                if (intern_end_counter = '1') then
                    led_cycle_cnt <= led_cycle_cnt + 1;
                end if;
            else
                led_cycle_cnt <= (others => '0');
            end if;

        end if;
    end process;

    -- combinatory logic

    -- demux logic
    -- red led blinks only if current_color_code = '01'
    led0_r <= led_state when current_color_code = "01" else '0';
    -- green led blinks only if current_color_code = '10'
    led0_g <= led_state when current_color_code = "10" else '0';
    -- green led blinks only if current_color_code = '11'
    led0_b <= led_state when current_color_code = "11" else '0';


    -- cycle counter logic
    cmp_led_cycle_cnt <= '1' when led_cycle_cnt >= led_cycle_cnt_limit else '0';
    
    end_cycle <= cmp_led_cycle_cnt; -- set the end_cycle output


    -- FSM
    -- we'll use 1 process for the 3 FSMs (1 for each led)
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