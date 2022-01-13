library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

-- makes edges from pulses
-- for each clock a '1' is seen on sig_in
-- sig_out toggles
entity edge_maker is
    port(
        clock : in std_logic;
        reset : in std_logic;
        sig_in : in std_logic;
        sig_out : out std_logic
        );
end;

architecture behavioral of edge_maker is
    signal reg_last_out: std_logic;
    signal next_last_out: std_logic;
begin
    -- registers
    process(clock)
    begin
        if rising_edge(clock) then
            if reset = '1' then
                reg_last_out <= '0';
            else -- not reset
                reg_last_out <= next_last_out;
            end if; -- reset / not
        end if; -- rising edge clock
    end process;
    -- next state
    next_last_out <= reg_last_out when sig_in = '0' else not reg_last_out;
    -- output
    sig_out <= reg_last_out;
end behavioral;
