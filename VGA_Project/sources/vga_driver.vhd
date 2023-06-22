library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity vga_driver is
    Port (
        -- inputs
        clk                 : in std_logic;
        reset               : in std_logic;
        -- outputs
        -- signals handling color intensity
        int_red             : out std_logic_vector(3 downto 0);
        int_green           : out std_logic_vector(3 downto 0);
        int_blue            : out std_logic_vector(3 downto 0);
        
        -- signals handling frame printing
        requested_pixel     : out std_logic_vector(11 downto 0); -- get the requested pixel from a frame buffer
        BRAM_rd_en          : out std_logic;
        vsync               : out std_logic;
        hsync               : out std_logic
    );
end vga_driver;

architecture Behavioral of vga_driver is

    signal h_is_in_display          : std_logic;
    signal v_is_in_display          : std_logic;
    signal is_in_display            : std_logic;
    signal cmp_end_line             : std_logic;
    signal cmp_end_frame            : std_logic;
    
    -- counters signal
    -- cols counter
    signal col_cnt                  : unsigned(9 downto 0);
    signal row_cnt                  : unsigned(9 downto 0);
    

begin

    process(clk, reset)
    begin
        if (reset = '1') then
            col_cnt <= to_unsigned(0, 10);
            row_cnt <= to_unsigned(0, 10);
        
        elsif (rising_edge(clk)) then
            -- increment the cols at each clock cycle
            if (cmp_end_line = '1') then
                col_cnt <= to_unsigned(0, 10);
            else
                col_cnt <= col_cnt + 1;
            end if;
            
            
            if (row_cnt = 524 and col_cnt = 639) then
                row_cnt <= to_unsigned(0, 10);
            else
                -- increment the rows when col_cnt = 639
                if (cmp_end_line = '1') then
                    row_cnt <= row_cnt + 1;
                end if;
            end if;
        
        end if;
    end process;

    -- combinatory logic
    
    -- cols logic 
    hsync <= '1' when (col_cnt >= 656) and (col_cnt < 752) else '0';
    h_is_in_display <= '1' when (col_cnt < 640) else '0';
    cmp_end_line <= '1' when col_cnt = 799 else '0';
    
    -- rows logic 
    vsync <= '1' when (col_cnt >= 656) and (col_cnt < 752) else '0';
    v_is_in_display <= '1' when (col_cnt < 640) else '0';
    
    BRAM_rd_en <= '1' when (col_cnt < 640) and (row_cnt < 480) else '0';
    
    -- get the next pixel to print on screen
    requested_pixel <= std_logic_vector((row_cnt * 640) + col_cnt);

end Behavioral;