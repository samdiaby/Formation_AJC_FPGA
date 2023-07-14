library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.NUMERIC_STD.all;

entity top_sobels is
    generic(
		PX_SIZE : integer := 8        -- taille d'un pixel
	);
	port(
		-- inputs
		resetn	: in std_logic;
		clk		: in std_logic;
		input_data	        : in std_logic_vector(PX_SIZE-1 downto 0);
		input_data_valid	: in std_logic;
		
		-- outputs
		output_data	        : out std_logic_vector(PX_SIZE-1 downto 0);
		output_data_valid	: out std_logic
	);
end top_sobels;


architecture behavioral of top_sobels is

    -- intern signals
    
    -- signals for img_reader
    signal input_data_in           : std_logic_vector(PX_SIZE-1 downto 0);
    signal input_data_valid_in     : std_logic;

    -- signals for sliding window
    signal pixel_from_img          : std_logic_vector(PX_SIZE-1 downto 0);
    signal pixel_from_img_valid    : std_logic;
    signal can_compute             : std_logic;
    signal p1_reg, p2_reg, p3_reg  : std_logic_vector(7 downto 0);
    
    -- pixels from line_2_buff
    signal p4_reg, p5_reg, p6_reg  : std_logic_vector(7 downto 0);
    
    -- latest gen pixels
    signal p7_reg, p8_reg, p9_reg  : std_logic_vector(7 downto 0);
    
    -- signals for out_x and out_y and the sum of it
    signal out_x                   : integer;
    signal out_y                   : integer;
    signal out_in                  : integer;
    
    -- signals for seuil
    constant const_seuil : integer := 1020;
    signal cmd_const_seuil : std_logic;
    
    -- signals for mux
    signal mux_out : std_logic_vector(7 downto 0);


    -- ajout des composants
    
    component text_image_reader is
        generic(
            PX_SIZE : integer := 8        -- taille d'un pixel
        );
        port(
            -- inputs
            resetn	: in std_logic;
            clk		: in std_logic;
            input_data	        : in std_logic_vector(PX_SIZE-1 downto 0);
            input_data_valid	: in std_logic;
            
            -- outputs
            output_data	        : out std_logic_vector(PX_SIZE-1 downto 0);
            output_data_valid	: out std_logic
        );
    end component;

    component sliding_window is
        generic(
            PX_SIZE             : integer := 8;        -- taille d'un pixel
            img_height          : natural;-- range 0 to 480;
            img_width           : natural-- range 0 to 640
        );
        Port (
            -- inputs
            clk                     : in std_logic;
            reset                   : in std_logic;
    
                -- signals from image reader
            latest_pixel            : in std_logic_vector(PX_SIZE-1 downto 0);
            pixel_valid             : in std_logic;
    
            -- outputs
                -- FIR_pix           : out std_logic_vector(7 downto 0);
                -- pixels register for convolution
                -- pixels from line_1_buff
            p1_reg, p2_reg, p3_reg  : out std_logic_vector(PX_SIZE-1 downto 0);
                -- pixels from line_2_buff
            p4_reg, p5_reg, p6_reg  : out std_logic_vector(PX_SIZE-1 downto 0);
                -- latest gen pixels
            p7_reg, p8_reg, p9_reg  : out std_logic_vector(PX_SIZE-1 downto 0);
            
            can_compute             : out std_logic
        );
    end component;
    
    component Sobel_x is

        port(
            -- inputs
            p1_reg   : in std_logic_vector(7 downto 0);
            p2_reg   : in std_logic_vector(7 downto 0) := (others => '0');
            p3_reg   : in std_logic_vector(7 downto 0);
            p4_reg   : in std_logic_vector(7 downto 0);
            p5_reg   : in std_logic_vector(7 downto 0) := (others => '0');
            p6_reg   : in std_logic_vector(7 downto 0);
            p7_reg   : in std_logic_vector(7 downto 0);
            p8_reg   : in std_logic_vector(7 downto 0) := (others => '0');
            p9_reg   : in std_logic_vector(7 downto 0);
            
            -- outputs
            out_x    : out integer

        );
    end component;

    component Sobel_y is

        port(
            -- inputs
            p1_reg   : in std_logic_vector(7 downto 0);
            p2_reg   : in std_logic_vector(7 downto 0);
            p3_reg   : in std_logic_vector(7 downto 0);
            p4_reg   : in std_logic_vector(7 downto 0) := (others => '0');
            p5_reg   : in std_logic_vector(7 downto 0) := (others => '0');
            p6_reg   : in std_logic_vector(7 downto 0) := (others => '0');
            p7_reg   : in std_logic_vector(7 downto 0);
            p8_reg   : in std_logic_vector(7 downto 0);
            p9_reg   : in std_logic_vector(7 downto 0);
            
            -- outputs
            out_y    : out integer      

        );
    end component;

begin

    -- img reader in instantiation
        -- this is used to read the image
        -- from a txt file
--    IMG_READER : text_image_reader
--    generic map(
--        PX_SIZE => 8        -- taille d'un pixel
--    )
--    port map(
--        resetn => resetn,
--        clk => clk,
--        input_data => input_data,
--        input_data_valid => input_data_valid,
--        output_data => pixel_from_img,
--        output_data_valid => pixel_from_img_valid
--    );

    -- img reader out instantiation
        -- this is used to write the image
        -- in a txt file
--    IMG_writer : text_image_reader
--    generic map(
--        PX_SIZE => 8        -- taille d'un pixel
--    )
--    port map(
--        resetn => resetn,
--        clk => clk,
--        input_data => mux_out,
--        input_data_valid => can_compute,
--        output_data => output_data,
--        output_data_valid => output_data_valid
--    );

    -- sliding window comp instantiation
    SLIDING_WINDOW_INST : sliding_window
    generic map(
        PX_SIZE => 8,        -- taille d'un pixel
        img_height => 64,
        img_width => 64
    )
    Port map(
        clk => clk,
        reset => resetn,
        
        -- signals from image reader
        latest_pixel => input_data,--pixel_from_img,
        pixel_valid => input_data_valid,--pixel_from_img_valid,
        
        -- FIR_pix           : out std_logic_vector(7 downto 0);
        -- pixels register for convolution
        -- pixels from line_1_buff
        p1_reg => p1_reg,
        p2_reg => p2_reg,
        p3_reg => p3_reg,
        -- pixels from line_2_buff
        p4_reg => p4_reg,
        p5_reg => p5_reg,
        p6_reg => p6_reg,
        -- latest gen pixels
        p7_reg => p7_reg,
        p8_reg => p8_reg,
        p9_reg => p9_reg,
        
        can_compute => output_data_valid
    );
    
    -- Sobel_x instantiation
    SOBEL_H_INST : Sobel_x
    port map(
        -- pixels from line_1_buff
        p1_reg => p1_reg,
        p2_reg => p2_reg,
        p3_reg => p3_reg,
        
        -- pixels from line_2_buff
        p4_reg => p4_reg,
        p5_reg => p5_reg,
        p6_reg => p6_reg,
        
        -- latest gen pixels
        p7_reg => p7_reg,
        p8_reg => p8_reg,
        p9_reg => p9_reg,
        out_x => out_x
    );

    -- Sobel_y instantiation
    SOBEL_V_INST : Sobel_y
    port map(
        -- pixels from line_1_buff
        p1_reg => p1_reg,
        p2_reg => p2_reg,
        p3_reg => p3_reg,
        
        -- pixels from line_2_buff
        p4_reg => p4_reg,
        p5_reg => p5_reg,
        p6_reg => p6_reg,
        
        -- latest gen pixels
        p7_reg => p7_reg,
        p8_reg => p8_reg,
        p9_reg => p9_reg,
        out_y => out_y
    );
    
    -- Logique Combinatoire
    
    out_in <= out_x + out_y;
    
    cmd_const_seuil <= '1' when out_in >= const_seuil else '0';
    
--    output_data <= p5_reg;
    
--    mux_out <= x"FF" when cmd_const_seuil = '1' 
--    else (others => '0');
    output_data <= x"FF" when cmd_const_seuil = '1' 
    else (others => '0');


end behavioral;