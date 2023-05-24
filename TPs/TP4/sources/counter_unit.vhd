library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;


entity counter_unit is
    generic(
        limit : unsigned(27 downto 0) := to_unsigned(100_000_000, 28)
    );
    port ( 
		clk			    : in std_logic;
        resetn		    : in std_logic;
        end_counter		: out std_logic
     );
end counter_unit;

architecture behavioral of counter_unit is
	
	--Declaration des signaux internes
	-- constant that will be used to stop the counter
    constant cnt_limit    : unsigned(27 downto 0) := limit;
    -- counter signal
	signal cnt            : unsigned(27 downto 0) := (others => '0');
    -- command signal for the mux
    signal cmd            : std_logic := '0';
    -- internal signal to store the comparison between 'cnt' and 'cnt_limit'
    signal cmp_cnt        : std_logic := '0';
    
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
			elsif(rising_edge(clk)) then
			    if cmd = '0' then
			        -- we add '1' to the counter at each rising_edge of clk
			        cnt <= cnt + 1;
			    else
			        -- the counter reached the limit value
			        -- -> we choose the '0' entry of the mux
			        cnt <= (others => '0');
			    end if;
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
        cmd <= cmp_cnt;
		
	    -- set 'end_counter' output signal according to the T flop output
	    -- (computed via the 'inter_end_counter' signal)
		end_counter <= cmp_cnt;

end behavioral;