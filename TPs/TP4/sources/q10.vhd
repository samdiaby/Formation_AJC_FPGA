library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity q10 is
    generic(
        limit : unsigned(27 downto 0) := to_unsigned(99_999_999, 28) -- generic param for counter_unit
    );
    port (
        -- inputs
		clk			    : in std_logic;
        resetn		    : in std_logic;
        btn0            : in std_logic;
        btn1		    : in std_logic;
        -- outputs
        led0_r          : out std_logic;
        led0_g          : out std_logic;
        led0_b          : out std_logic
     );
end q10;

architecture behavioral of q10 is

    -- color codes constants
    constant green_color_code   : std_logic_vector(1 downto 0) := "10";
    constant blue_color_code    : std_logic_vector(1 downto 0) := "11";

    -- internal signal to handle 'update' signal behaviour
    -- (btn0 logic from Q9)
    signal intern_update        : std_logic := '0';
    
    -- register to keep the previous value of the btn0 signal
    signal is_btn0_pressed      : std_logic := '0';
    
    -- internal signal representing the output
    -- of the color code constant mux
    -- (default is blue)
    signal selected_color       : std_logic_vector(1 downto 0) := blue_color_code;

    -- led_driver declaration
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
            led0_b          : out std_logic
        );
    end component;

begin

    -- the 'led_driver' we will use in this entity
    COMP_LED_DRIVER : led_driver
    generic map (
       limit => limit -- set this value to change the time between LED blinks
    )
    port map (
        -- inputs
        clk => clk,
        resetn => resetn,
        color_code => selected_color,
        update => intern_update,
        -- outputs
        led0_r => led0_r,
        led0_g => led0_g,
        led0_b => led0_b
    );

    -- handle the FSM current state
    process(clk, resetn)
    begin
        if (resetn = '1') then
            is_btn0_pressed <= '0';
            intern_update <= '0';

        elsif (rising_edge(clk)) then
            is_btn0_pressed <= btn0;
            -- we want update to be '1' only once (during 1 clock cycle)
            -- when 'btn0' is pressed and 'is_btn0_pressed' = '0' (if btn0 wasn't pressed before)
            intern_update <= btn0 and (not is_btn0_pressed);

        end if;
    end process;

    -- combinatory logic
    
    -- mux to choose between 'blue' and 'green'
    -- according to the btn1 signal
    selected_color <= green_color_code when btn1 = '1' else blue_color_code;

end behavioral;