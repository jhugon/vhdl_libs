library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

-- Debounce switch input
-- Based on https://github.com/brimdavis/yard-1/tree/master/hdl/common/debounce by Briam Davis
-- tick should be a single clock pulse coming every ~ 10 ms
-- reset value is the output you want the FFs to be reset to. Usually the neutral position of the switch/button.
entity switch_debouncer is
    port(
        clock : in std_logic;
        reset : in std_logic;
        reset_value : in std_logic;
        tick: in std_logic;
        sig_in : in std_logic;
        sig_out : out std_logic
        );
end;

architecture behavioral of switch_debouncer is
    signal sample_reg : std_logic;
    signal stable_flag_reg : std_logic;
    signal out_reg : std_logic;
    signal sample_next : std_logic;
    signal stable_flag_next : std_logic;
    signal out_next : std_logic;
begin
    -- registers
    process(clock)
    begin
        if rising_edge(clock) then
            if reset = '1' then
                sample_reg <= reset_value;
                stable_flag_reg <= '0';
                out_reg <= reset_value;
            else -- not reset
                sample_reg <= sample_next;
                stable_flag_reg <= stable_flag_next;
                out_reg <= out_next;
            end if; -- reset / not
        end if; -- rising edge clock
    end process;
    -- next state
    -- only sample on ticks (and also reset stable_flag on ticks)
    -- in between ticks, unset stable flag if sig_in differs from sample_reg
    -- only update output on ticks if stable_flag is set
    sample_next <= sig_in when tick = '1' else sample_reg;
    stable_flag_next <= '1' when tick = '1' else stable_flag_reg and (sample_reg xnor sig_in);
    out_next <= sample_reg when (tick = '1') and (stable_flag_reg = '1') else out_reg;
    -- output
    sig_out <= out_reg;
end behavioral;
