--+----------------------------------------------------------------------------
--|
--| NAMING CONVENSIONS :
--|
--|    xb_<port name>           = off-chip bidirectional port ( _pads file )
--|    xi_<port name>           = off-chip input port         ( _pads file )
--|    xo_<port name>           = off-chip output port        ( _pads file )
--|    b_<port name>            = on-chip bidirectional port
--|    i_<port name>            = on-chip input port
--|    o_<port name>            = on-chip output port
--|    c_<signal name>          = combinatorial signal
--|    f_<signal name>          = synchronous signal
--|    ff_<signal name>         = pipeline stage (ff_, fff_, etc.)
--|    <signal name>_n          = active low signal
--|    w_<signal name>          = top level wiring signal
--|    g_<generic name>         = generic
--|    k_<constant name>        = constant
--|    v_<variable name>        = variable
--|    sm_<state machine type>  = state machine type definition
--|    s_<signal name>          = state name
--|
--+----------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;


entity top_basys3 is
    port(
        -- inputs
        clk     :   in std_logic; -- native 100MHz FPGA clock
        sw      :   in std_logic_vector(7 downto 0); -- operands and opcode
        btnU    :   in std_logic; -- reset
        btnL    :   in std_logic;
        btnC    :   in std_logic; -- fsm cycle
        
        -- outputs
        led :   out std_logic_vector(15 downto 0);
        -- 7-segment display segments (active-low cathodes)
        seg :   out std_logic_vector(6 downto 0);
        -- 7-segment display active-low enables (anodes)
        an  :   out std_logic_vector(3 downto 0)
    );
end top_basys3;

architecture top_basys3_arch of top_basys3 is 
  
	-- declare components and signals
component controller_fsm is
    Port ( i_reset : in STD_LOGIC;
           i_adv : in STD_LOGIC;
           o_cycle : out STD_LOGIC_VECTOR (3 downto 0)
           );
end component controller_fsm;

component clock_divider is
	generic ( constant k_DIV : natural := 2	);
	port ( 	i_clk    : in std_logic;		   -- basys3 clk
			i_reset  : in std_logic;		   -- asynchronous
			o_clk    : out std_logic		   -- divided (slow) clock
   );
end component clock_divider;

component ALU is 
    Port ( i_A : in STD_LOGIC_VECTOR (7 downto 0);
           i_B : in STD_LOGIC_VECTOR (7 downto 0);
           i_op : in STD_LOGIC_VECTOR (2 downto 0);
           o_result : out STD_LOGIC_VECTOR (7 downto 0);
           o_flags : out STD_LOGIC_VECTOR (3 downto 0));
end component ALU;

component twos_comp is
port (
        i_bin: in std_logic_vector(7 downto 0);
        o_sign: out std_logic;
        o_hund: out std_logic_vector(3 downto 0);
        o_tens: out std_logic_vector(3 downto 0);
        o_ones: out std_logic_vector(3 downto 0)
    );
end component twos_comp;

component TDM4 is
generic ( constant k_WIDTH : natural  := 4); -- bits in input and output
    Port ( i_clk		: in  STD_LOGIC;
           i_reset		: in  STD_LOGIC; -- asynchronous
           i_D3 		: in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
		   i_D2 		: in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
		   i_D1 		: in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
		   i_D0 		: in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
		   o_data		: out STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
		   o_sel		: out STD_LOGIC_VECTOR (3 downto 0)	-- selected data line (one-cold)
	);
end component TDM4;

component sevenseg_decoder is
Port ( i_Hex : in STD_LOGIC_VECTOR (3 downto 0);
       o_seg_n : out STD_LOGIC_VECTOR (6 downto 0));
end component sevenseg_decoder;
           	
signal w_cycle: std_logic_vector (3 downto 0);
signal w_clk: std_logic;
signal w_A: std_logic_vector (7 downto 0);
signal w_B: std_logic_vector (7 downto 0);           	
signal w_result: std_logic_vector (7 downto 0);
signal w_bin: std_logic_vector (3 downto 0);
signal w_sign: std_logic;
signal w_hund: std_logic_vector (3 downto 0);
signal w_tens: std_logic_vector (3 downto 0);
signal w_ones: std_logic_vector (3 downto 0);
signal w_data: std_logic_vector (3 downto 0);
signal w_sel: std_logic_vector (3 downto 0);
signal w_seg: std_logic_vector (6 downto 0);
signal w_reset: std_logic;
signal w_D3: std_logic_vector (3 downto 0);


begin
	-- PORT MAPS ----------------------------------------
controller : controller_fsm
    port map(
        i_reset => btnU,
        i_adv => btnC,
        o_cycle => w_cycle
        );
        
clkdiv_inst : clock_divider 		--instantiation of clock_divider to take 
        generic map ( k_DIV => 10000 ) 
        port map (						  
            i_clk   => clk,
            i_reset => btnL,
            o_clk   => w_clk
        ); 
	
ALU_inst : ALU
    port map (
        i_A => w_A,
        i_B => w_B,
        i_op => sw(2 downto 0),
        o_flags => led(15 downto 12),
        o_result => w_result
        );
        
twos : twos_comp
    port map(
        i_bin => w_bin,
        o_sign => w_sign,
        o_hund => w_hund,
        o_tens => w_tens,
        o_ones => w_ones
        );
        
TDM : TDM4
    generic map (k_WIDTH => 4)
    port map(
        i_clk => w_clk,
        i_reset => btnL,
        i_D3 => w_D3,
        i_D2 => w_hund,
        i_D1 => w_tens,
        i_D0 => w_ones,
        o_data => w_data,
        o_sel => w_sel
        );
        
decoder : sevenseg_decoder
    port map( 
        i_hex => w_data,
        o_seg_n => w_seg
        );
	-- CONCURRENT STATEMENTS ----------------------------
w_D3 <= "000" & w_sign;

with w_cycle select
    w_bin <= "00000000" when "0001",
             w_A when "0010",
             w_B when "0100",
             w_result when "1000",
             "00000000" when others;
	
REG_A : process(w_cycle)
begin   
    if rising_edge(w_cycle(1)) then
        w_A <= sw(7 downto 0);
    end if;
end process REG_A;

REG_B : process(w_cycle)
begin
    if rising_edge(w_cycle(2)) then
        w_B <= sw(7 downto 0);
    end if;
end process REG_B;

with w_sel select
    seg <= "1000000" when "0111",
           w_seg when others;
    
an <= w_sel;

end top_basys3_arch;
