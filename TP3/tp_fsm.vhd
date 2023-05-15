library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity tp_fsm is
    generic (
        --vous pouvez ajouter des parametres generics ici
        limit : unsigned(27 downto 0) := to_unsigned(100000000, 28) -- use in counter_unit
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
end tp_fsm;

architecture behavioral of tp_fsm is

--    type state is (idle, state1, state2); --a modifier avec vos etats
    type state is (White_led, Red_led, Blue_led, Green_led); --a modifier avec vos etats
    
    signal current_state : state;  --etat dans lequel on se trouve actuellement
    signal next_state : state;	   --etat dans lequel on passera au prochain coup d'horloge
    
    -- counter 
    -- intern_end_counter_cnt -> Q output of the flip flop in RTL
    signal intern_end_counter_cnt : std_logic_vector(27 downto 0) := (others => '0');
    signal cmp_iecc : std_logic; -- iecc = intern_end_counter_cnt -> will store the result of the comp between iecc and the constant "5"
    
    -- limit value for the 'intern_end_counter_cnt'
    -- will be use to count the number of 'on/off' led cycles (from 0 to 5 -> 6 cycles)
    constant iecc_limit : positive := 10#5#; 
    
    -- muxes cmd signals
    signal cmd_cnt_incr : std_logic := '0'; -- will allow to choose to increment the counter or not
    signal cmd_cnt_restart : std_logic := '0'; -- will allow to choose to increment the counter or not

    -- keep the state of the leds to make them blink
    -- led_state will be inversed each time cmd_cnt_incr will be set to 1
    signal led_state : std_logic := '0';

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
            end_counter => cmd_cnt_incr
        );


		process(clk,resetn)
		begin
            if(resetn='1') then
                current_state <= White_led;

                -- reset counter
                intern_end_counter_cnt <= (others => '0');
                 
			elsif(rising_edge(clk)) then
			
				current_state <= next_state;
				
				--a completer avec votre compteur de cycles
				-- counter incr mux
				if cmd_cnt_incr = '1' then
				    intern_end_counter_cnt <= std_logic_vector(unsigned(intern_end_counter_cnt) + 1);
				-- else -> keep the prevoius value of 'intern_end_counter_cnt'
				end if;
				
				-- counter restart mux
				if cmd_cnt_restart = '1' then
				    intern_end_counter_cnt <= (others => '0');
				-- else -> keep the prevoius value of 'intern_end_counter_cnt'
				end if;

            end if;
		end process;


		-- combinatory logic
		
		-- command signal for the mux that will "reset" the counter 'intern_end_counter_cnt'
		-- the counter is reset when 1 of these 2 conds are met :
		--    - the 'restart' button is pressed
		--    - the 'cmp_iecc' is set to '1'
		cmd_cnt_restart <= restart or cmp_iecc;
		-- cmd_cnt_incr -> set by the signal 'end_counter' of the counter_unit
		
		-- condition used to pass to next state
		-- we pass to the next state when these 2 conds are met : 
		--    - 'intern_end_counter_cnt' count 6 cycles (intern_end_counter_cnt = 5)
		--    - 'cmd_cnt_incr' (end_counter signal from 'counter_unit') is set to '1'
		cmp_iecc <= '1' when intern_end_counter_cnt >= iecc_limit and cmd_cnt_incr = '1' else '0';

        -- check the state of 'intern_end_counter_cnt'
        -- to determine if the led should be 'on' or 'off'
		led_state <= '0' when (unsigned(intern_end_counter_cnt) mod 2) = 0 else '1';
		

		-- FSM
		process(current_state, cmp_iecc, led_state, restart) --a completer avec vos signaux
		begin
		  
		  -- next_state is set to current_state at the begining of the process
		  -- to avoid it to be 'undifined' later if not set in the case statement
           next_state <= current_state;

           case current_state is
              when White_led =>
                if restart = '1' then -- count reset to '0' -> return to initial state
                    next_state <= White_led;
                elsif cmp_iecc = '1' then -- We counted 6 on/off cycles for this state -> go to the next one
                    next_state <= Red_led;
                end if;
                
                --signaux pilotes par la fsm
                -- set the RGB led 0 to white
                led0_r <= led_state;
                led0_g <= led_state;
                led0_b <= led_state;
                
                -- set the RGB led 1 to white
                led1_r <= led_state;
                led1_g <= led_state;
                led1_b <= led_state;
    
              when Red_led =>
                if restart = '1' then -- count reset to '0' -> return to initial state
                    next_state <= White_led;
                elsif cmp_iecc = '1' then -- We counted 6 on/off cycles for this state -> go to the next one
                    next_state <= Blue_led; 
                end if;
                
                --signaux pilotes par la fsm
                -- set the RGB led 0 to red
                led0_r <= led_state;
                led0_g <= '0';
                led0_b <= '0';
                
                -- set the RGB led 1 to red
                led1_r <= led_state;
                led1_g <= '0';
                led1_b <= '0';
              
              when Blue_led =>
                if restart = '1' then -- count reset to '0' -> return to initial state
                    next_state <= White_led;
                elsif cmp_iecc = '1' then -- We counted 6 on/off cycles for this state -> go to the next one
                    next_state <= Green_led;
                end if;
                
                --signaux pilotes par la fsm
                -- set the RGB led to blue
                led0_r <= '0';
                led0_g <= '0';
                led0_b <= led_state;
                
                -- set the RGB led 1 to blue
                led1_r <= '0';
                led1_g <= '0';
                led1_b <= led_state;
              
              when Green_led =>
                if restart = '1' then -- count reset to '0' -> return to initial state
                    next_state <= White_led;
                elsif cmp_iecc = '1' then -- We counted 6 on/off cycles for this state -> go to the next one
                    next_state <= Red_led;
                end if;
                
                --signaux pilotes par la fsm
                -- set the RGB led 0 to green
                led0_r <= '0';
                led0_g <= led_state;
                led0_b <= '0';
              
              -- set the RGB led 1 to green
                led1_r <= '0';
                led1_g <= led_state;
                led1_b <= '0';
              
              end case;

		end process;

end behavioral;