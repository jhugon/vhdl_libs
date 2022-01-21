library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

-- in_segments is each digit's segment signals concatenated, most significant
-- digit with the highest index.
--
-- out_segments is the multiplexed 7-segment output, synchronized with digit_enables.
--
-- digit_enables sets each digit high in turn, most significan digi, highest index
--
-- Want to switch digit between 60 Hz and 1000 Hz
-- So ceil(log2(ClockFreq/1000)) is the number of bits and should be close
entity seven_seg_digit_mux is
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
end seven_seg_digit_mux;

architecture behavioral of seven_seg_digit_mux is
    component simple_timer is
        generic(Nbits: integer := 10); -- N bits to use for counter
        port(
            clock : in std_logic;
            reset : in std_logic;
            enable : in std_logic;
            count : out std_logic_vector(Nbits - 1 downto 0)
        );
    end component;
    signal timer_count : std_logic_vector(integer(ceil(log2(real(ClockFreq/1000)))) -1 downto 0);
    signal iDigit_reg : std_logic_vector(integer(ceil(log2(real(Ndigits))))-1 downto 0) := (others => '0');
    signal iDigit_next : std_logic_vector(integer(ceil(log2(real(Ndigits))))-1 downto 0);
    constant timer_zero : unsigned := to_unsigned(0,integer(ceil(log2(real(ClockFreq/1000)))));
begin
    -- components
    timer : simple_timer
        generic map (Nbits => integer(ceil(log2(real(ClockFreq/1000)))))
        port map (
            clock => clock,
            reset => '0',
            enable => '1',
            count => timer_count
        );
    -- registers
    reg_proc : process(clock)
    begin
        if rising_edge(clock) then
            iDigit_reg <= iDigit_next;
        end if;
    end process;
    -- next state
    proc_next_state : process(timer_count,iDigit_reg)
        variable iDigit_int_loc : integer;
    begin
        iDigit_int_loc := to_integer(unsigned(iDigit_reg));
        if timer_count = std_logic_vector(timer_zero) then
            if iDigit_int_loc+1 >= Ndigits then
                iDigit_next <= (others => '0');
            else
                iDigit_next <= std_logic_vector(to_unsigned(iDigit_int_loc+1,integer(ceil(log2(real(Ndigits))))));
            end if;
        else
            iDigit_next <= iDigit_reg;
        end if;
    end process;
    -- output
    proc_output : process(in_segments,iDigit_reg)
        variable iDigit_int_loc : integer;
    begin
        iDigit_int_loc := to_integer(unsigned(iDigit_reg));
        for i in 0 to Ndigits - 1 loop
            if i = iDigit_int_loc then
                digit_enables(i) <= '1';
            else
                digit_enables(i) <= '0';
            end if;
        end loop;
        out_segments <= in_segments((iDigit_int_loc+1)*7-1 downto iDigit_int_loc*7);
    end process;
end behavioral;
