library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity top is
    generic(N_DIGITS: integer := 4;
            CLK_FREQ: integer := 100000000;
            TICK_FREQ: integer := 10);
    port(clk : in std_logic;
        seg : out std_logic_vector(6 downto 0);
        an : out std_logic_vector(N_DIGITS-1 downto 0));
end;

architecture behavioral of top is
    component simple_timer is
        generic(Nbits: integer := 10); -- N bits to use for counter
        port(
            clock : in std_logic;
            reset : in std_logic;
            enable : in std_logic;
            count : out std_logic_vector(Nbits - 1 downto 0)
        );
    end component;
    component seven_seg_dec_display is
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
    end component;
    signal count :  std_logic_vector(integer(floor(log2(real(CLK_FREQ/TICK_FREQ))))+integer(ceil(log2(real(10**N_DIGITS-1))))-1 downto 0);
    signal seg_enables : std_logic_vector(6 downto 0);
    signal digit_enables : std_logic_vector(N_DIGITS-1 downto 0);
    constant in_num_bits : integer := integer(ceil(log2(real(10**N_DIGITS-1))));
    constant timer_n_bits : integer := integer(floor(log2(real(CLK_FREQ/TICK_FREQ))))+integer(ceil(log2(real(10**N_DIGITS-1))));
begin
    -- submodules
    timer : simple_timer
        generic map (Nbits => timer_n_bits)
        port map (
            clock => clk,
            reset => '0',
            enable => '1',
            count => count
        );
    display : seven_seg_dec_display
        generic map (Ndigits => N_DIGITS, ClockFreq => CLK_FREQ)
        port map (
            clock => clk,
            in_num => count(count'length-1 downto count'length-in_num_bits),
            out_segments => seg_enables,
            digit_enables => digit_enables
        );
    -- logic
    seg <= not seg_enables;
    an <= not digit_enables;
end behavioral;
