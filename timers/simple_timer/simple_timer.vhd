library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Timer with reset and enable
-- 
-- Meant to be used as a timer, or a counter (by hooking up edge_detector to enable)
--
-- Goes back to zero after wrapping around
-- 
-- clock: if enable is 1, counts clock ticks
-- reset: sychronous with clock, sets count to 0. Requires 1 clock
-- enable: when high counts on each clock tick, so will count pulses
--          e.g. if output by edge detector. That's how you make it
--          a counter
-- count: current count. Goes from 0 to 2**Nbits-1.
entity simple_timer is
    generic(Nbits: integer := 10); -- N bits to use for counter
    port(
        clock : in std_logic;
        reset : in std_logic;
        enable : in std_logic;
        count : out std_logic_vector(Nbits - 1 downto 0)
    );
end simple_timer;

architecture behavioral of simple_timer is
    signal count_reg : std_logic_vector(Nbits - 1 downto 0) := std_logic_vector(to_unsigned(0,Nbits));
    signal count_next : std_logic_vector(Nbits - 1 downto 0);
begin
    -- registers
    process(clock)
    begin
        if rising_edge(clock) then
            if reset = '1' then
                count_reg <= (others => '0');
            else
                count_reg <= count_next;
            end if;
        end if;
    end process;
    -- next state
    count_next <= std_logic_vector(to_unsigned((to_integer(unsigned(count_reg))+1) mod (2**Nbits),Nbits)) when (enable = '1') else count_reg;
    -- output
    count <= count_reg;
end behavioral;
