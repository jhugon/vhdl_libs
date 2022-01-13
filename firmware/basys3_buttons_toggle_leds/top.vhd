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
    signal tick : std_logic;
    signal led0 : std_logic;
begin
-- submodules
tg : button_toggler
    port map (
        clock => clk,
        reset => '0',
        reset_value => '0',
        tick => tick,
        sig_in => btnC,
        sig_out => led0
    );
tmr : programmable_timer_pulser
    generic map (Nbits => 8)
    port map (
        clock => clk,
        reset => '0',
        enable => '1',
        max_value => std_logic_vector(to_unsigned(255,8)),
        trigger_only_wraparound => '0',
        trigger => tick
    );
-- output logic
led(0) <= led0;
end behavioral;
