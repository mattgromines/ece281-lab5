----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/18/2025 02:50:18 PM
-- Design Name: 
-- Module Name: ALU - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ALU is
    Port ( i_A : in STD_LOGIC_VECTOR (7 downto 0);
           i_B : in STD_LOGIC_VECTOR (7 downto 0);
           i_op : in STD_LOGIC_VECTOR (2 downto 0);
           o_result : out STD_LOGIC_VECTOR (7 downto 0);
           o_flags : out STD_LOGIC_VECTOR (3 downto 0));
end ALU;

architecture Behavioral of ALU is
    signal w_or :        std_logic_vector (7 downto 0);
    signal w_and :       std_logic_vector (7 downto 0);
    signal w_xnor:       std_logic;
    signal w_xor:        std_logic;
    signal w_not:        std_logic;
    signal w_adder_mux : std_logic_vector (7 downto 0);
    signal w_adder :     std_logic_vector (7 downto 0);
    signal w_carry0:     std_logic;
    signal w_carry1:     std_logic;
    signal w_result:     std_logic_vector (7 downto 0);
    signal w_nots:       std_logic_vector (7 downto 0);
begin

    w_or <= i_A or i_B;
    
    w_and <= i_A and i_B;
    
    w_xnor <= not(i_A(7) xor i_B(7) xor i_op(0));
    
    w_not <= not(i_op(1));
    
    with i_op select
    
        w_adder_mux <= i_B when "000" | "010",
                    not(i_B) when "001" | "011",
                    (others => '0') when others;
    
    ripple_adder_0: entity work.ripple_adder

    port map(
        A => i_A(3 downto 0),
        B => w_adder_mux(3 downto 0),
        Cin => i_op(0),
        S => w_adder(3 downto 0),
        Cout => w_carry0
    );
    
    ripple_adder_1: entity work.ripple_adder

    port map(
        A => i_A(7 downto 4),
        B => w_adder_mux(7 downto 4),
        Cin => w_carry0,
        S => w_adder(7 downto 4),
        Cout => w_carry1
     );
     
     w_xor <= i_A(7) xor w_adder(7);
    
     with i_op select
        
     w_result <= w_adder when "000" | "001",
                 w_and   when "010",
                 w_or    when "011",
                 (others => '0') when others;
                 
    o_result <= w_result;
    
    o_flags(3) <= w_result(7);
    
    w_nots <= not(w_result);
    
    o_flags(2) <= '1' when w_result = "00000000" else '0';
    
    o_flags(1) <= (w_not and w_carry1);
    
    o_flags(0) <= (w_xnor and w_xor and w_not);
    
    
    
end Behavioral;
