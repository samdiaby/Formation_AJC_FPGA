library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity top is
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
end top;

architecture behavioral of top is

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

    -- 'end_cycle' internal signal needed
    -- to use the output in the entity
    signal intern_end_cycle     : std_logic;
    

    -- signals to handle FIFO logic
    -- internal signal that will be passed to the rd_en input of the FIFO
    signal intern_rd_en          : std_logic := '0'; 
    -- internal signal that will be passed to the wr_en input of the FIFO
    signal intern_wr_en          : std_logic := '0'; 
    
    -- FIFO output color (from a read)
    signal fifo_dout_color      : std_logic_vector(1 downto 0);
    -- FIFO full signal
    signal fifo_full            : std_logic;
    -- FIFO empty signal
    signal fifo_empty           : std_logic;

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
            led0_b          : out std_logic;
            end_cycle       : out std_logic
        );
    end component;
    
    -- FIFO declaration
    component fifo_generator_0 is
        port (
        -- inputs
            clk     : in std_logic;
            srst     : in std_logic;
            din     : in std_logic_vector(1 downto 0);
            wr_en   : in std_logic;
            rd_en   : in std_logic;
        -- outputs
            dout    : out std_logic_vector(1 downto 0);
            full    : out std_logic;
            empty   : out std_logic
        );
    end component;

begin

    -- the 'led_driver' instance we will use in this entity
    COMP_LED_DRIVER : led_driver
    generic map (
       limit => limit -- set this value to change the time between LED blinks
    )
    port map (
    -- inputs
        clk => clk,
        resetn => resetn,
        color_code => fifo_dout_color, -- FIFO read output color
        update => intern_update,
    -- outputs
        led0_r => led0_r,
        led0_g => led0_g,
        led0_b => led0_b,
        end_cycle => intern_end_cycle
    );
    
    -- the 'fifo_generator_0' instance we will use in this entity
    FIFO_ISNT : fifo_generator_0
    port map (
    -- inputs
        clk => clk,
        srst => resetn,
        din => selected_color, -- mux output color
        wr_en => intern_wr_en,
        rd_en => intern_rd_en,
    -- outputs
        dout => fifo_dout_color,
        full => fifo_full,
        empty => fifo_empty
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
    
    -- We want 'rd_en' (FIFO input for reading)
    -- to be '1' when the FIFO is not empty and 'end_cycle' is 1
    intern_rd_en <= '1' when (fifo_empty = '0') and (intern_end_cycle = '1') else '0';

    -- We want 'wr_en' (FIFO input for writing)
    -- to be '1' when the FIFO is not full and 'intern_update' is 1 (the btn 0 has been pressed)
    intern_wr_en <= '1' when (fifo_full = '0') and (intern_update = '1') else '0';

end behavioral;