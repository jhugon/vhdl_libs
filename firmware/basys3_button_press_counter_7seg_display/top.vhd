library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity top is
    generic(N_DIGITS: integer := 4;
            CLK_FREQ: integer := 100000000;
            DEBOUNCE_TICK_FREQ: integer := 100);
    port(clk : in std_logic;
        btnC: in std_logic;
        btnU: in std_logic;
        seg : out std_logic_vector(6 downto 0);
        an : out std_logic_vector(N_DIGITS-1 downto 0));
end;

architecture behavioral of top is
    component double_flip_flop is
        port(
            clock : in std_logic;
            reset : in std_logic;
            sig_in : in std_logic;
            sig_out : out std_logic
            );
    end component;
    component switch_debouncer is
        port(
            clock : in std_logic;
            reset : in std_logic;
            reset_value : in std_logic;
            tick: in std_logic;
            sig_in : in std_logic;
            sig_out : out std_logic
            );
    end component;
    component edge_detector_rising is
        port(
            clock : in std_logic;
            reset : in std_logic;
            sig_in : in std_logic;
            sig_out : out std_logic
            );
    end component;
    component switch_input is
        port(
            clock : in std_logic;
            reset : in std_logic;
            reset_value : in std_logic;
            tick: in std_logic;
            sig_in : in std_logic;
            sig_out : out std_logic;
            falling_edge_pulse : out std_logic;
            rising_edge_pulse : out std_logic
            );
    end component;
    component programmable_timer_pulser is
        generic(Nbits: integer := 10); -- N bits to use for counter
        port(
            clock : in std_logic;
            reset : in std_logic;
            enable : in std_logic;
            max_value : in std_logic_vector(Nbits - 1 downto 0);
            trigger_only_wraparound : in std_logic;
            count : out std_logic_vector(Nbits - 1 downto 0);
            trigger : out std_logic
        );
    end component;
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

    constant display_bits : integer := integer(ceil(log2(real(10**N_DIGITS-1))));
    constant debounce_timer_max_int : integer := CLK_FREQ/DEBOUNCE_TICK_FREQ;
    constant debounce_timer_max_nbits : integer := integer(ceil(log2(real(debounce_timer_max_int+1))));
    constant debounce_timer_max : unsigned(debounce_timer_max_nbits-1 downto 0) := to_unsigned(debounce_timer_max_int,debounce_timer_max_nbits);

    signal btnC_sync : std_logic;
    signal btnU_sync : std_logic;
    signal btnC_debounced : std_logic;
    signal debounce_tick : std_logic;
    signal btnC_edge : std_logic;
    signal btnU_edge : std_logic;
    signal btn_edge_combined : std_logic;

    signal count : std_logic_vector(display_bits-1 downto 0);
    signal seg_enables : std_logic_vector(6 downto 0);
    signal digit_enables : std_logic_vector(N_DIGITS-1 downto 0);
begin
    -- submodules
    btnC_sw_input : switch_input
        port map(
            clock => clk,
            reset => '0',
            reset_value => '0',
            tick => debounce_tick,
            sig_in => btnC,
            rising_edge_pulse => btnC_edge
            );
    btnU_dbl_ff : double_flip_flop
        port map (
            clock => clk,
            reset => '0',
            sig_in => btnU,
            sig_out => btnU_sync
        );
    debounce_timer_pulser : programmable_timer_pulser
        generic map (Nbits => debounce_timer_max_nbits)
        port map (
            clock => clk,
            reset => '0',
            enable => '1',
            max_value => std_logic_vector(debounce_timer_max),
            trigger_only_wraparound => '0',
            trigger => debounce_tick
        );
    btnU_edge_det : edge_detector_rising
        port map (
            clock => clk,
            reset => '0',
            sig_in => btnU_sync,
            sig_out => btnU_edge
        );
    counter : simple_timer
        generic map (Nbits => display_bits)
        port map (
            clock => clk,
            reset => '0',
            enable => btn_edge_combined,
            count => count
        );
    dec_display : seven_seg_dec_display
        generic map (Ndigits => N_DIGITS, ClockFreq => CLK_FREQ)
        port map (
            clock => clk,
            in_num => count,
            out_segments => seg_enables,
            digit_enables => digit_enables
        );
    -- logic
    btn_edge_combined <= btnC_edge or btnU_edge;
    -- output
    seg <= not seg_enables;
    an <= not digit_enables;
end behavioral;
