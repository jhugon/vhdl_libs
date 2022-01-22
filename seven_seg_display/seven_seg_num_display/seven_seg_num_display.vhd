library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

-- out_segments is the multiplexed 7-segment output, synchronized with digit_enables.
--
-- digit_enables sets each digit high in turn, most significan digi, highest index
entity seven_seg_num_display is
    generic (
        Ndigits : integer := 2;
        ClockFreq : integer := 100000000 -- in Hz
    );
    port(
        clock : in std_logic;
        in_num : in std_logic_vector(integer(ceil(log2(real(10**Ndigits-1))))-1 downto 0);
        out_segments : out std_logic_vector(6 downto 0);
        digit_enables : out std_logic_vector(Ndigits-1 downto 0)
    );
end seven_seg_num_display;

architecture behavioral of seven_seg_num_display is
    component seven_seg_digit_mux is
        generic (
            Ndigits : integer := 2;
            ClockFreq : integer := 100000000 -- in Hz
        );
        port(
            clock : in std_logic;
            in_segments : in std_logic_vector(Ndigits*7-1 downto 0);
            out_segments : out std_logic_vector(6 downto 0);
            digit_enables : out std_logic_vector(Ndigits-1 downto 0)
        );
    end component;
    component seven_seg_decoder is
        port(
            in_data : in std_logic_vector(3 downto 0);
            out_segments : out std_logic_vector(6 downto 0)
        );
    end component;
    component binary_to_bcd_converter is
        generic (
            Ndigits : integer := 2
        );
        port(
            clock : in std_logic;
            in_num : in std_logic_vector(integer(ceil(log2(real(10**Ndigits-1))))-1 downto 0);
            out_digits : out std_logic_vector(Ndigits*4-1 downto 0)
        );
    end component;
    signal decoded_segments : std_logic_vector(Ndigits*7-1 downto 0);
    signal converted_reg : std_logic_vector(Ndigits*4-1 downto 0) := std_logic_vector(to_unsigned(0,Ndigits*4));
    signal converted_next : std_logic_vector(Ndigits*4-1 downto 0);
    type digit_int_array is array (Ndigits-1 downto 0) of integer;
    type digit_unsigned_array is array (Ndigits-1 downto 0) of unsigned(3 downto 0);
begin
    -- components
    mux : seven_seg_digit_mux
        generic map (Ndigits => Ndigits, ClockFreq => ClockFreq)
        port map (
            clock => clock,
            in_segments => decoded_segments,
            out_segments => out_segments,
            digit_enables => digit_enables
        );
    gen_decoder : for i in 0 to Ndigits-1 generate
        decoder : seven_seg_decoder
            port map (
                in_data => converted_reg((i+1)*4-1 downto i*4),
                out_segments => decoded_segments((i+1)*7-1 downto i*7)
            );
    end generate;
    -- registers
    reg_proc : process(clock)
    begin
        if rising_edge(clock) then
            converted_reg <= converted_next;
        end if;
    end process;
    -- next state
    proc_next_state : process(in_num)
        variable digits : digit_unsigned_array;
    begin
        -- from https://my.eng.utah.edu/~nmcdonal/Tutorials/BCDTutorial/BCDConversion.html
        for i in Ndigits-1 to 0 loop
            digits(i) := (others => '0');
        end loop;
        for iBit in 0 to in_num'length-1 loop
            for i in Ndigits-1 to 0 loop
                if to_integer(digits(i)) >= 5 then
                    digits(i) := to_unsigned(to_integer(digits(i))+3,4);
                end if;
            end loop;
            for i in Ndigits-1 to 1 loop
                digits(i) := shift_left(digits(i),1);
                digits(i)(0) := digits(i-1)(3);
            end loop;
            digits(0) := shift_left(digits(0),1);
            digits(0)(0) := in_num(iBit);
        end loop;
        for i in Ndigits-1 to 0 loop
            converted_next((i+1)*4-1 downto i*4) <= std_logic_vector(digits(i));
        end loop;
    end process;
    -- output
end behavioral;
