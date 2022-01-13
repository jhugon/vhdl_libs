library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

-- Debounce and handles metastability on switch input
-- Uses button press edges to toggle output on and off
-- tick should be a single clock pulse coming every ~ 10 ms
-- reset value is the output you want the debouncer FFs to be reset to. Usually the neutral position of the switch/button.
-- Not sure, but may take 2 clocks after the 2nd tick for a toggle to happen (unless too close to tick, then 3 ticks)
entity button_toggler is
    port(
        clock : in std_logic;
        reset : in std_logic;
        reset_value : in std_logic;
        tick: in std_logic;
        sig_in : in std_logic;
        sig_out : out std_logic
        );
end;

architecture behavioral of button_toggler is
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
    component edge_maker is
        port(
            clock : in std_logic;
            reset : in std_logic;
            sig_in : in std_logic;
            sig_out : out std_logic
            );
    end component;
    signal pulse : std_logic;
begin
-- submodules
sw : switch_input
    port map (
        clock => clock,
        reset => reset,
        reset_value => reset_value,
        tick => tick,
        sig_in => sig_in,
        rising_edge_pulse => pulse
    );
em : edge_maker
    port map (
        clock => clock,
        reset => reset,
        sig_in => pulse,
        sig_out => sig_out
    );
end behavioral;
