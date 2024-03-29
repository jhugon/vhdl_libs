library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

-- Decodes unisgned 4-bit numbers into hex digits
-- out_segments is high for each segment to be on
-- segment order (from LSB to MSB) is:
-- top, ur, lr, bot, ll, ul, center
-- 0    1   2   3     4   5   6
entity seven_seg_decoder is
    port(
        in_data : in std_logic_vector(3 downto 0);
        out_segments : out std_logic_vector(6 downto 0)
    );
end seven_seg_decoder;

architecture behavioral of seven_seg_decoder is
begin
    with in_data select
        out_segments <= "0111111" when "0000",
                        "0000110" when "0001",
                        "1011011" when "0010",
                        "1001111" when "0011",
                        "1100110" when "0100",
                        "1101101" when "0101",
                        "1111101" when "0110",
                        "0000111" when "0111",
                        "1111111" when "1000",
                        "1101111" when "1001",
                        "1110111" when "1010",
                        "1111100" when "1011",
                        "0111001" when "1100",
                        "1011110" when "1101",
                        "1111001" when "1110",
                        "1110001" when "1111",
                        "0000000" when others;
end behavioral;
