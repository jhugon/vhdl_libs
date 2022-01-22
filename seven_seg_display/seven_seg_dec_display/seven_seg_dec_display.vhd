library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

-- out_segments is the multiplexed 7-segment output, synchronized with digit_enables.
--
-- digit_enables sets each digit high in turn, most significan digi, highest index
entity seven_seg_dec_display is
    generic (
        Ndigits : integer := 2;
        ClockFreq : integer := 100000000; -- in Hz
        do_hex : integer := 0 -- if 0, then decimal, if 1, then hex
    );
    port(
        clock : in std_logic;
        in_num : in std_logic_vector(integer(ceil(log2(real(10**Ndigits-1))))-1 downto 0);
        out_segments : out std_logic_vector(6 downto 0);
        digit_enables : out std_logic_vector(Ndigits-1 downto 0)
    );
end seven_seg_dec_display;

architecture behavioral of seven_seg_dec_display is
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
    signal converted: std_logic_vector(Ndigits*4-1 downto 0) := std_logic_vector(to_unsigned(0,Ndigits*4));
begin
    -- components
    bcd_conv : binary_to_bcd_converter
        generic map (Ndigits => Ndigits)
        port map (
            clock => clock,
            in_num => in_num,
            out_digits => converted
        );
    gen_decoder : for i in 0 to Ndigits-1 generate
        decoder : seven_seg_decoder
            port map (
                in_data => converted((i+1)*4-1 downto i*4),
                out_segments => decoded_segments((i+1)*7-1 downto i*7)
            );
    end generate;
    mux : seven_seg_digit_mux
        generic map (Ndigits => Ndigits, ClockFreq => ClockFreq)
        port map (
            clock => clock,
            in_segments => decoded_segments,
            out_segments => out_segments,
            digit_enables => digit_enables
        );
end behavioral;
