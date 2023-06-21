library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity q1 is
    generic(
        limit : unsigned(27 downto 0) := to_unsigned(99_999_999, 28) -- generic param for counter_unit
    );
    port (
        -- inputs
        clkA			: in std_logic;
		clkB		    : in std_logic;
        resetn		    : in std_logic;
        -- outputs
        led0            : out std_logic_vector(2 downto 0);
        led1            : out std_logic_vector(2 downto 0)
     );
end q1;

architecture behavioral of q1 is

    -- FSM states declaration
    type state is (Init, Led_red, Led_blue, Led_green);
    
    signal current_state    : state;  --etat dans lequel on se trouve actuellement
    signal next_state       : state;  --etat dans lequel on passera au prochain coup d'horloge

    -- the led color to output 
    signal current_led_color    : std_logic_vector(1 downto 0) := (others => '0');

    -- 
    signal end_cycle_in1         : std_logic := '0';
    signal end_cycle_in2         : std_logic := '0';
    
--    -- Button 0 logic
--    signal button0_in           : std_logic := '0';
--    signal button0_out          : std_logic := '0';
    
    -- muxes logic
    signal mux_end_cycle1       : std_logic_vector(3 downto 0) := (others => '0');
    signal mux_end_cycle2       : std_logic_vector(3 downto 0) := (others => '0');
   
    
    -- 'end_end_cycle' counter logic
    -- constant to limit the number of 'end_cycle' to count
    -- we need to count 10 'end_cycle'
    constant end_end_cycle_limit    : std_logic_vector(3 downto 0) := "1001"; -- 9
    
    -- internal signal for the cycle counter
    signal end_end_cycle            : std_logic_vector(3 downto 0) := (others => '0');

    -- result of the comparison of 'end_end_cycle' and 'end_end_cycle_limit'
    signal cmp_end_cycle            : std_logic := '0';

    signal next_state_cond          : std_logic := '0';

    -- signals to handle the resetn case
    signal reset_update             : std_logic;
    signal update_in                : std_logic;
    
       -- registres allongement signal
   signal cmd_update_in         : std_logic;
   signal mux_strech_cnt1       : std_logic_vector(3 downto 0) := (others => '0');
   signal mux_strech_cnt2       : std_logic_vector(3 downto 0) := (others => '0');
   signal strech_cnt            : std_logic_vector(3 downto 0) := (others => '0');
   signal u_in_streched         : std_logic := '0';
   signal uins_meta             : std_logic := '0';
   signal uins_stable           : std_logic := '0';

    -- counter_unit declaration
    component led_driver
        generic(
            limit : unsigned(27 downto 0) := limit
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
    end component;

begin

    -- the first 'led_driver' we will use in this entity
    LED_DRIVER_INST1 : led_driver
    generic map (
       limit => limit -- set this value to change the time between LED blinks
    )
    port map (
        -- inputs
        clk => clkA,
        resetn => resetn,
        color_code => current_led_color,
        update => update_in,
        -- outputs
        led0_r => led0(0),
        led0_g => led0(1),
        led0_b => led0(2),
        end_cycle => end_cycle_in1
    );

    -- the second 'led_driver' we will use in this entity
    LED_DRIVER_INST2 : led_driver
    generic map (
       limit => limit -- set this value to change the time between LED blinks
    )
    port map (
        -- inputs
        clk => clkB,
        resetn => resetn,
        color_code => current_led_color,
        update => uins_stable,
        -- outputs
        led0_r => led1(0),
        led0_g => led1(1),
        led0_b => led1(2),
        end_cycle => end_cycle_in2
    );

    -- handle the FSM current state
    -- and all logic associated to "clka"
    process(clkA, resetn)--, update)
    begin
        if (resetn = '1') then
            current_state <= Init;

            -- reset 'end_cycle' counter register
            end_end_cycle <= (others => '0');
            update_in <= '0';

        elsif (rising_edge(clkA)) then
            current_state <= next_state;
            end_end_cycle <= mux_end_cycle2;
            strech_cnt <= mux_strech_cnt2;
            
            if (reset_update = '1' OR next_state_cond = '1') then
                update_in <= '1';
            else
                update_in <= '0';
            end if;

        end if;
    end process;
    
    -- This process handle the Cross Clocking Domain
    -- to let 'LED_DRIVER_INST2' see the 'update_in'
    -- go from '0' to '1'. we use 2 registers
    -- to avoid any metastabilities issues
    process(clkB)
    begin
        if (rising_edge(clkB)) then
            uins_meta <= u_in_streched;
            uins_stable <= uins_meta;
        end if;
        
    end process;
    
    -- FSM
    -- FSM that handle the led color according to the blink count (end_end_cycle)
    -- change state each 10 blinks
    process(current_state, next_state_cond)
    begin

        -- next_state is set to current state as default
        next_state <= current_state;

        case current_state is
            when Init =>
                -- change FSM state
                if resetn = '0' then
                    next_state <= Led_red;
                end if;

                -- execute state logic
                current_led_color <= "00";
                reset_update <= '1';

            when Led_red =>
                -- change FSM state
                if next_state_cond = '1' then
                    next_state <= Led_blue;
                end if;

                -- execute state logic
                current_led_color <= "01";
                reset_update <= '0';

            when Led_blue =>
                -- change FSM 
                if next_state_cond = '1' then
                    next_state <= Led_green;
                end if;

                -- execute state logic
                current_led_color <= "11";
                reset_update <= '0';

             when Led_green =>
                -- change FSM 
                if next_state_cond = '1' then
                    next_state <= Led_red;
                end if;

                -- execute state logic
                current_led_color <= "10";
                reset_update <= '0';

                
        end case; 
    end process;
    
-- combinatory logic

cmp_end_cycle <= '1' when end_end_cycle = "1001" -- = '9'
                    else '0';

next_state_cond <= '1' when cmp_end_cycle = '1' AND end_cycle_in1 = '1' else '0';

mux_end_cycle2 <= mux_end_cycle1 when next_state_cond = '0' else (others => '0');
mux_end_cycle1 <= end_end_cycle when end_cycle_in1 = '0' else end_end_cycle + '1';

cmd_update_in <= update_in;

-- strech the update_in signal through 5 clkA periods (count from 0 to 4)
mux_strech_cnt2 <= mux_strech_cnt1 when cmd_update_in = '0' else "0100";  
mux_strech_cnt1 <= strech_cnt when u_in_streched = '0' else strech_cnt - '1';

u_in_streched <= '1' when strech_cnt > "0000" else '0';


end behavioral;