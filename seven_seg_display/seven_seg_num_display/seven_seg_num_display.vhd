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
        in_num : in std_logic_vector(floor(log2(10**Ndigits-1))-1 downto 0);
        out_segments : out std_logic_vector(Ndigits*7-1 downto 0);
        digit_enables : out std_logic_vector(Ndigits-1 downto 0)
    );
end seven_seg_num_display;

architecture behavioral of seven_seg_num_display is
    component seven_seg_decoder is
        port(
            in_data : in std_logic_vector(3 downto 0);
            out_segments : out std_logic_vector(6 downto 0)
        );
    end component;
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
    signal decoded_segments : std_logic_vector(Ndigits*7-1 downto 0);
    signal converted_reg : std_logic_vector(Ndigits*7-1 downto 0) := std_logic_vector(to_unsigned(0,Ndigits*7));
    signal converted_next : std_logic_vector(Ndigits*7-1 downto 0);
begin
    -- components

    -- need multiple of these?
    decoder : seven_seg_decoder
        port map (
            in_data => converted_reg(???),
            out_segments => decoded_segments(???)
        );
    mux : seven_seg_digit_mux
        generic map (Ndigits => Ndigits, ClockFreq => ClockFreq)
        port map (
            clock => clock,
            in_segments => decoded_segments,
            out_segments => out_segments,
            digit_enables => digit_enables
        );
    -- registers
    reg_proc : process(clock)
    begin
        if rising_edge(clock) then
            converted_reg <= converted_next;
        end if;
    end process;
    -- next state
    proc_next_state : process(in_num)
    begin
        converted_next <= ???;
    end process;
    -- output
end behavioral;
