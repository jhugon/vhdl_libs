library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Timer with reset, enable, and trigger value
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
entity triggerable_timer is
    generic(Nbits: integer := 10); -- N bits to use for counter
    port(
        clock : in std_logic;
        reset : in std_logic;
        enable : in std_logic;
        max_value : in std_logic_vector(Nbits - 1 downto 0);
        count : out std_logic_vector(Nbits - 1 downto 0);
        trigger : out std_logic
    );
end triggerable_timer;

architecture behavioral of triggerable_timer is
    component programmable_timer is
        generic(Nbits: integer := 10); -- N bits to use for counter
        port(
            clock : in std_logic;
            reset : in std_logic;
            enable : in std_logic;
            max_value : in std_logic_vector(Nbits - 1 downto 0);
            count : out std_logic_vector(Nbits - 1 downto 0)
        );
    end component;
    signal trigger_internal: std_logic;
    signal count_internal: std_logic_vector(Nbits - 1 downto 0);
    signal last_count: std_logic_vector(Nbits - 1 downto 0);
    signal count_num: unsigned(Nbits - 1 downto 0);
begin
    simple_timer_inst : programmable_timer
        generic map (Nbits => Nbits)
        port map (
            clock => clock,
            reset => reset,
            enable => enable,
            max_value => max_value,
            count => count_internal
        );
    -- registers
    process(clock)
    begin
        if rising_edge(clock) then
            if reset = '1' then
                last_count <= (others => '0');
            else
                last_count <= count_internal;
            end if;
        end if;
    end process;
    -- bookkeeping
    count_num <= unsigned(count_internal);
    -- logic
    trigger_internal <= '1' when (count_num = 0) and (last_count = max_value) else '0';
    -- output
    count <= count_internal;
    trigger <= trigger_internal;
    
end behavioral;
