library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

-- in_num is an unsigned binary number
-- outdigits is 4 bits per digit, lowest digit, lowest signal.
--
-- from https://my.eng.utah.edu/~nmcdonal/Tutorials/BCDTutorial/BCDConversion.html
entity binary_to_bcd_converter is
    generic (
        Ndigits : integer := 2
    );
    port(
        clock : in std_logic;
        in_num : in std_logic_vector(integer(ceil(log2(real(10**Ndigits-1))))-1 downto 0);
        out_digits : out std_logic_vector(Ndigits*4-1 downto 0)
    );
end binary_to_bcd_converter;

architecture behavioral of binary_to_bcd_converter is
    type digit_int_array is array (Ndigits-1 downto 0) of integer;
    type digit_unsigned_array is array (Ndigits-1 downto 0) of unsigned(3 downto 0);
    signal out_digits_next : std_logic_vector(Ndigits*4-1 downto 0);
begin
    -- registers
    reg_proc : process(clock)
    begin
        if rising_edge(clock) then
            out_digits <= out_digits_next;
        end if;
    end process;
    -- next state
    proc_next_state : process(in_num)
        variable digits : digit_unsigned_array;
    begin
        for i in Ndigits-1 downto 0 loop
            digits(i) := (others => '0');
        end loop;
        for iBit in in_num'length-1  downto 0 loop
            for i in Ndigits-1 downto 0 loop
                if to_integer(digits(i)) >= 5 then
                    digits(i) := to_unsigned(to_integer(digits(i))+3,4);
                end if;
            end loop;
            for i in Ndigits-1 downto 1 loop
                digits(i) := shift_left(digits(i),1);
                digits(i)(0) := digits(i-1)(3);
            end loop;
            digits(0) := shift_left(digits(0),1);
            digits(0)(0) := in_num(iBit);
        end loop;
        for i in Ndigits-1 downto 0 loop
            out_digits_next((i+1)*4-1 downto i*4) <= std_logic_vector(digits(i));
        end loop;
    end process;
    -- output
end behavioral;
