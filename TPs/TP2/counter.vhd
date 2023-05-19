library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;


entity counter_unit is
    port ( 
		clk			    : in std_logic;
        resetn		    : in std_logic;
        restart         : in std_logic; -- add for question 10
        end_counter		: out std_logic
     );
end counter_unit;

architecture behavioral of counter_unit is
	
	--Declaration des signaux internes
	-- counter limit value : 4 (count to 50 ns)
	constant test_const        : positive := 10#4#;
	-- counter limit value : 200 000 000 - 1 (count to 2 s)
	constant targeted_const    : positive := 16#BEBC1FF#;
	-- constant that will be used to stop the counter
    constant cnt_limit          : positive := targeted_const;
    -- counter signal
	signal cnt                 : std_logic_vector(27 downto 0) := (others => '0');
    -- command signal for the mux
    signal cmd            : std_logic := '0';
    -- internal signal to store the comparison between 'cnt' and 'cnt_limit'
    signal cmp_cnt        : std_logic := '0';
    -- internal signal to store the output signal
    -- to be able to use it as an entry for the T flop
    signal intern_end_counter       : std_logic := '0';

	begin

		--Partie sequentielle
		
		-- Use the same process to create the 28 bits counter + the T flop
		-- The 28 bits counter uses the signals : cmd, cnt
		-- The T flop uses the signals : intern_end_counter, 
		process(clk, resetn)
		begin
		    -- begin counter logic
			if(resetn = '1') then
			    cnt <= (others => '0'); -- reset triggered -> clear the counter
			    intern_end_counter <= '0'; -- reset triggered -> clear the T flop
			elsif(rising_edge(clk)) then
			    if cmd = '0' then
			        -- we add '1' to the counter at each rising_edge of clk
			        cnt <= std_logic_vector(unsigned(cnt) + 1);
			    else
			        -- the counter reached the limit value
			        -- -> we choose the '0' entry of the mux
			        cnt <= (others => '0');
			    end if;
			    
			    -- begin T flop logic (to store end_counter result (2s temp))
                intern_end_counter <= cmp_cnt xor intern_end_counter;
		        -- end T flop logic
			end if;
			-- end counter logic
		end process;
		
		--Partie combinatoire
		
		-- if cnt >= cnt_limit -> cmp_cnt = 1 -> the counter reached the allowed limit
		-- in every other case -> cmp_cnt = '0'
		-- we don't set 'end_counter' directly because
		-- we won't be able to use it later to set the 'cmd' signal
		-- (because it's an output signal)
		cmp_cnt <= '1' when cnt >= cnt_limit else '0';

		-- set the cmd bit according to the restart button and the 'cnt_limit' const
        cmd <= restart or cmp_cnt;
		
	    -- set 'end_counter' output signal according to the T flop output
	    -- (computed via the 'inter_end_counter' signal)
		end_counter <= intern_end_counter;

end behavioral;