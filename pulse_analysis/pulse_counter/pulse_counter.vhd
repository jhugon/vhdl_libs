library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity pulse_counter is
    generic(Nbits: integer := 10); -- size of counter
    port(
        clock : in std_logic;
        reset : in std_logic;
        enable : in std_logic;
        sig_in : in std_logic;
        count : out std_logic_vector(Nbits -1 downto 0)
        );
end;

architecture behavioral of pulse_counter is
    component simple_timer is
        generic(Nbits: integer := 10); -- N bits to use for counter
        port(
            clock : in std_logic;
            reset : in std_logic;
            enable : in std_logic;
            count : out std_logic_vector(Nbits - 1 downto 0)
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
    signal edge_pulse : std_logic;
    signal enable_counter : std_logic;
begin
    counter : simple_timer
        generic map (Nbits => Nbits)
        port map (
            clock => clock,
            reset => reset,
            enable => enable_counter,
            count => count
        );
    edge_det : edge_detector_rising
        port map (
            clock => clock,
            reset => reset,
            sig_in => sig_in,
            sig_out => edge_pulse
        );
    enable_counter <= '1' when edge_pulse = '1' and enable = '1' else '0';
end behavioral;
