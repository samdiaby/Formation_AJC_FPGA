library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_q10 is
end tb_q10;

architecture behavioral of tb_q10 is

    -- input signals for 'tp_fsm'
	signal resetn          : std_logic := '0';
	signal clk             : std_logic := '0';
	signal btn0            : std_logic := '0';
    signal btn1            : std_logic := '0';

	-- output signals for 'tp_fsm' (rgb led)
    signal led0_g          : std_logic := '0';
    signal led0_r          : std_logic := '0';
    signal led0_b          : std_logic := '0';
	
	-- constants for 'tp_fsm'

    -- cu_cnt_limit -> counter_unit_count_limit
	-- will be used to determine the count limit for 1 'half on/off cycle' for the leds
	constant cu_cnt_limit  : unsigned := to_unsigned(4, 28);

    -- tb internal signals for 'current_color_code'
    signal tb_curr_color_code : std_logic_vector(1 downto 0) := (others => '0');

	-- Les constantes suivantes permette de definir la frequence de l'horloge
	constant hp        : time := 5 ns;  --demi periode de 5ns
	constant period    : time := 2*hp;  --periode de 10ns, soit une frequence de 100Hz


	component q10
        generic(
            limit : unsigned(27 downto 0)
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
	end component;

        -- begin util functions
        -- define function to avoid duplication in tb

        -- test if all the leds are 'off'
        function AreLedsOff(led0_r : std_logic;
                               led0_g : std_logic;
                               led0_b : std_logic)
        return boolean is
        begin
           return (led0_r = '0' and led0_g = '0' and led0_b = '0');
        end function;

        -- Test if the red led is the only led 'on'
        function IsRedLedOn(led0_r : std_logic;
                               led0_g : std_logic;
                               led0_b : std_logic)
        return boolean is
        begin
           return (led0_r = '1' and led0_g = '0' and led0_b = '0');
        end function;

        -- Test if the red led is the only led 'on'
        function IsGreenLedOn(led0_r : std_logic;
                               led0_g : std_logic;
                               led0_b : std_logic)
        return boolean is
        begin
           return (led0_r = '0' and led0_g = '1' and led0_b = '0');
        end function;

        -- Test if the red led is the only led 'on'
        function IsBlueLedOn(led0_r : std_logic;
                               led0_g : std_logic;
                               led0_b : std_logic)
        return boolean is
        begin
           return (led0_r = '0' and led0_g = '0' and led0_b = '1');
        end function;
        -- end util functions
	begin

	-- isntanciate a led_driver instance
	dut: q10
	    generic map (
	       limit => cu_cnt_limit
	    )
        port map (
            clk => clk, 
            resetn => resetn,
			btn0 => btn0,
			btn1 => btn1,
			led0_g => led0_g,
			led0_r => led0_r,
			led0_b => led0_b
        );

	--Simulation du signal d'horloge en continue
	process
    begin
		wait for hp;
		clk <= not clk;
	end process;


    -- this process is used to change the btn1 signal each 30ns (3 periods)
    -- to test the behaviour of the led_driver unit
    btn1_tester : process
        -- period to wait before the iecc counter is incremented by 1
        variable btn1_period    : time := 3 * period;
    begin

        wait for btn1_period;
        btn1 <= not btn1;

    end process btn1_tester;


    -- this process is used to change the update each 60ns (6 periods)
    -- to test the behaviour of the led_driver unit
    btn0_tester : process
        -- period to wait before the iecc counter is incremented by 1
        variable btn0_period    : time := 5 * period;
    begin

        wait for btn0_period;
        btn0 <= not btn0;

    end process btn0_tester;


	process
	   -- initial resetn period
	   variable resetn_period  : time := 5 * period;
	   -- period to wait before the iecc counter is incremented by 1
	   variable iec_period     : time := to_integer(cu_cnt_limit + 1) * period;

	   	-- test for getting internal signal of the 'dut' -> led_driver -- -> work for vhdl 2008
--	   	alias tb_current_color_code is << signal .tb_led_driver.dut.current_color_code : std_logic_vector(1 downto 0)>>; 
	begin

--        resetn <= '1';
--        wait for resetn_period;    
--        resetn <= '0';

--        loop
--            wait for hp; -- align on rising edges
    
--            if btn1 = '0' then
--                assert (IsBlueLedOn(led0_r, led0_g, led0_b) or AreLedsOff(led0_r, led0_g, led0_b))
--                report "Error : Led behaviour is incorect. \n Expected : led0_r = '0', led0_g = '0', led0_b = '0'."
--                severity failure;
                   
--            else
--                assert (IsGreenLedOn(led0_r, led0_g, led0_b) or AreLedsOff(led0_r, led0_g, led0_b)) -- faux ici
--                report "Error : Led behaviour is incorect. \n Expected : led0_r = '1', led0_g = '0', led0_b = '0' or led0_r = '0', led0_g = '0', led0_b = '0'."
--                severity failure;
--            end if;
--	   end loop;
	   
		wait;
	end process;
	
	
end behavioral;