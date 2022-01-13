library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Timer with reset, enable, and max_value
-- 
-- Meant to be used as a timer, or a counter (by hooking up edge_detector to enable)
--
-- Goes back to zero after reaching max_value
-- 
-- clock: if enable is 1, counts clock ticks
-- reset: sychronous with clock, sets count to 0. Requires 1 clock
-- enable: when high counts on each clock tick, so will count pulses
--          e.g. if output by edge detector. That's how you make it
--          a counter
-- max_value: maximum count gets to before going back to 0
-- count: current count. Goes from 0 to max_value.
entity programmable_timer is
    generic(Nbits: integer := 10); -- N bits to use for counter
    port(
        clock : in std_logic;
        reset : in std_logic;
        enable : in std_logic;
        max_value : in std_logic_vector(Nbits - 1 downto 0);
        count : out std_logic_vector(Nbits - 1 downto 0)
    );
end programmable_timer;

architecture behavioral of programmable_timer is
    component simple_timer is
        generic(Nbits: integer := 10); -- N bits to use for counter
        port(
            clock : in std_logic;
            reset : in std_logic;
            enable : in std_logic;
            count : out std_logic_vector(Nbits - 1 downto 0)
        );
    end component;
    signal combined_reset: std_logic;
    signal count_internal: std_logic_vector(Nbits - 1 downto 0);
    signal rollover_reset: std_logic;
begin
    simple_timer_inst : simple_timer
        generic map (Nbits => Nbits)
        port map (
            clock => clock,
            reset => combined_reset,
            enable => enable,
            count => count_internal
        );
    -- logic
    rollover_reset <= '1' when count_internal = max_value else '0';
    combined_reset <= reset or rollover_reset;
    -- output
    count <= count_internal;
    
end behavioral;
