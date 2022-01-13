library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

-- Debounce and handles metastability on switch input
-- tick should be a single clock pulse coming every ~ 10 ms
-- reset value is the output you want the debouncer FFs to be reset to. Usually the neutral position of the switch/button.
entity switch_input is
    port(
        clock : in std_logic;
        reset : in std_logic;
        reset_value : in std_logic;
        tick: in std_logic;
        sig_in : in std_logic;
        sig_out : out std_logic
        );
end;

architecture behavioral of switch_input is
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
    signal debouncer_input : std_logic;
begin
dbl_ff : double_flip_flop
    port map (
        clock => clock,
        reset => reset,
        sig_in => sig_in,
        sig_out => debouncer_input
    );
debouncer : switch_debouncer
    port map (
        clock => clock,
        reset => reset,
        reset_value => reset_value,
        tick => tick,
        sig_in => debouncer_input,
        sig_out => sig_out
    );
end behavioral;
