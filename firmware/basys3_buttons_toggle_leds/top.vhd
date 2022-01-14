library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity top is
    port(
        clk : in std_logic;
        btnC : in std_logic;
        led : out std_logic_vector(0 downto 0)
        );
end;

architecture behavioral of top is
    component button_toggler is
        port(
            clock : in std_logic;
            reset : in std_logic;
            reset_value : in std_logic;
            tick: in std_logic;
            sig_in : in std_logic;
            sig_out : out std_logic
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
    component reset_timer is
        generic(Nbits: integer := 4); -- N bits to use for counter
        port(
            clock : in std_logic;
            count_to_reset : in std_logic_vector(Nbits - 1 downto 0);
            reset : out std_logic
        );
    end component;
    signal tick : std_logic;
    signal led0 : std_logic;
    signal reset : std_logic;
begin
-- submodules
btn_tglr : button_toggler
    port map (
        clock => clk,
        reset => reset,
        reset_value => '0',
        tick => tick,
        sig_in => btnC,
        sig_out => led0
    );
timer_plsr : programmable_timer_pulser
    generic map (Nbits => 17) 
    port map (
        clock => clk,
        reset => reset,
        enable => '1',
        max_value => std_logic_vector(to_unsigned(100000,17)), -- needs to be 10 for testing, but for 10 MHz => 100 Hz need 100_000
        trigger_only_wraparound => '0',
        trigger => tick
    );
reset_ctrlr : reset_timer
    generic map (Nbits => 4)
    port map (
        clock => clk,
        count_to_reset => std_logic_vector(to_unsigned(15,4)),
        reset => reset
    );
-- output logic
led(0) <= led0;
end behavioral;
