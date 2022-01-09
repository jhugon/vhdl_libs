library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity edge_detector_rising is
    port(
        clock : in std_logic;
        reset : in std_logic;
        sig_in : in std_logic;
        sig_out : out std_logic
        );
end;

architecture behavioral of edge_detector_rising is
    component edge_detector is
        port(
            clock : in std_logic;
            reset : in std_logic;
            trig_on_rising : in std_logic;
            trig_on_falling : in std_logic;
            sig_in : in std_logic;
            sig_out : out std_logic
            );
    end component;
    signal current_in : std_logic;
    signal last_in : std_logic;
    signal last_last_in : std_logic;
begin
    rising_edge_detector : edge_detector
    port map(
        clock => clock,
        reset => reset,
        trig_on_rising => '1',
        trig_on_falling => '0',
        sig_in => sig_in,
        sig_out => sig_out
    );
end behavioral;
