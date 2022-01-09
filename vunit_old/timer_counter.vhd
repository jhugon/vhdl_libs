library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library vunit_lib;
context vunit_lib.vunit_context;

-- Timer-counter with reset and enable
-- 
-- Meant to be used as a timer, counter, or to drive PWM
-- Goes back to zero after interval counts (and triggers)
-- 
-- clock: if enable is 1, counts clock ticks
-- reset: sychronous with clock. Requires 1 clock
-- enable: when high counts on each clock tick, so will count pulses
--          e.g. if output by edge detector. That's how you make it
--          a counter
-- interval: ticks between triggers
-- count: current count. Goes from 0 to interval -1. Starts at zero
--          the clock tick reset goes from 1 to 0.
-- trigger: sends out a positive pulse tick after count = interval - 1
--          (count will be zero at that time)
entity counter_timer is
    generic(Nbits: integer); -- N bits to use for counter
    port(
        clock : in std_logic;
        reset : in std_logic;
        enable : in std_logic;
        interval in std_logic_vector(Nbits - 1 downto 0): 
        count : out std_logic_vector(Nbits - 1 downto 0);
        trigger : out std_logic);
end counter_timer;

architecture behavioral of counter_timer is
    signal count_next : std_logic_vector(Nbits - 1 downto 0);
begin
    -- registers
    process(clock)
      variable count_num : unsigned(Nbits - 1 downto 0);
    begin
        if rising_edge(clock) then
            log("counter-timer register updating...");
            log(  "count: " & to_string(count) 
                & " count_next: " & to_string(count_next) 
                & " reset: " & to_string(reset)
                & " enable: " & to_string(enable)
                & " interval: " & to_string(interval)
                & " trigger: " & to_string(trigger)
                );
            count_num := unsigned(count);
            next_count_num := count_num + 1;
            if reset  then
                count <= (others => '0');
                count_next <= std_logic_vector(to_unsigned(1,count'length));
                trigger <= 0;
            elseif next_count_num = unsigned(interval) then
                count <= (others => '0');
                count_next <= std_logic_vector(to_unsigned(1,count'length));
                trigger <= 1;
            else
                count <= std_logic_vector(count_next_num);
                count_next <= std_logic_vector(count_next_num);
                trigger <= 0;
            end if; -- reset or next_count_num = top
        end if; -- rising edge clock
    end process;
end behavioral;
