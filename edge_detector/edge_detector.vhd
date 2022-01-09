library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity edge_detector is
    port(
        clock : in std_logic;
        reset : in std_logic;
        trig_on_rising : in std_logic;
        trig_on_falling : in std_logic;
        sig_in : in std_logic;
        sig_out : out std_logic
        );
end;

architecture behavioral of edge_detector is
    signal current_in : std_logic;
    signal last_in : std_logic;
    signal last_last_in : std_logic;
begin
    -- registers
    process(clock)
    begin
        if rising_edge(clock) then
            if reset = '1' then
                last_in <= '0';
                last_last_in <= '0';
            else -- not reset
                last_in <= current_in;
                last_last_in <= last_in;
            end if; -- reset / not
        end if; -- rising edge clock
    end process;
    -- next state
    current_in <= sig_in;
    -- output
    sig_out <= (trig_on_rising and (last_in and (not last_last_in))) or (trig_on_falling and ((not last_in) and last_last_in));
end behavioral;
