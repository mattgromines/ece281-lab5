----------------------------------------------------------------------------------
-- Engineer: C1C Matthew Romines
-- 
-- Create Date: 03/04/2025 03:51:16 PM
-- Design Name: sevenseg_decoder
-- Module Name: sevenseg_decoder - Behavioral
-- Project Name: Lab 2
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

entity sevenseg_decoder is
    Port ( i_Hex : in STD_LOGIC_VECTOR (3 downto 0);
           o_seg_n : out STD_LOGIC_VECTOR (6 downto 0));
end sevenseg_decoder;

architecture Behavioral of sevenseg_decoder is
    signal o_seg : std_logic_vector (6 downto 0);
begin
    with i_Hex select
    -- manually fliped the bit order to accommodate the basys3
    -- there is probably a more efficient way to do this
    o_seg <= "0111111" when "0000",
             "0000110" when "0001",
             "1011011" when "0010",
             "1001111" when "0011",
             "1100110" when "0100",
             "1101101" when "0101",
             "1111101" when "0110",
             "0000111" when "0111",
             "1111111" when "1000",
             "1100111" when "1001",
             "1110111" when "1010",
             "1111100" when "1011",
             "1011000" when "1100",
             "1011110" when "1101",
             "1111001" when "1110",
             "1110001" when "1111",
             "0000000" when others;
             
     o_seg_n <=  NOT(o_seg);

end Behavioral;
