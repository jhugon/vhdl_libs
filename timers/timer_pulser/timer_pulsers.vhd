library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity simple_timer_pulser is
    generic(Nbits: integer := 10); -- N bits to use for counter
    port(
        clock : in std_logic;
        reset : in std_logic;
        enable : in std_logic;
        trigger_only_wraparound : in std_logic;
        count : out std_logic_vector(Nbits - 1 downto 0);
        trigger : out std_logic
    );
end simple_timer_pulser;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity programmable_timer_pulser is
    generic(Nbits: integer := 10); -- N bits to use for counter
    port(
        clock : in std_logic;
        reset : in std_logic;
        enable : in std_logic;
        max_value : in std_logic_vector(Nbits - 1 downto 0);
        trigger_only_wraparound : in std_logic;
        count : out std_logic_vector(Nbits - 1 downto 0);
        trigger : out std_logic
    );
end programmable_timer_pulser;


architecture compositional of simple_timer_pulser is
    component simple_timer is
        generic(Nbits: integer := 10); -- N bits to use for counter
        port(
            clock : in std_logic;
            reset : in std_logic;
            enable : in std_logic;
            count : out std_logic_vector(Nbits - 1 downto 0)
        );
    end component;
    component timer_pulser is
        generic(Nbits: integer := 10); -- N bits to use for counter
        port(
            clock : in std_logic;
            reset : in std_logic;
            count : in std_logic_vector(Nbits - 1 downto 0);
            trigger_only_wraparound : in std_logic;
            trigger : out std_logic
        );
    end component;
begin
timer: simple_timer
    generic map (
        Nbits => Nbits
    )
    port map (
        clock => clock,
        reset => reset,
        enable => enable,
        count => count
    );
pulser: timer_pulser
    generic map (
        Nbits => Nbits
    )
    port map (
        clock => clock,
        reset => reset,
        count => count,
        trigger_only_wraparound => trigger_only_wraparound,
        trigger => trigger
    );
end compositional;

architecture compositional of programmable_timer_pulser is
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
    component timer_pulser is
        generic(Nbits: integer := 10); -- N bits to use for counter
        port(
            clock : in std_logic;
            reset : in std_logic;
            count : in std_logic_vector(Nbits - 1 downto 0);
            trigger_only_wraparound : in std_logic;
            trigger : out std_logic
        );
    end component;
begin
timer: programmable_timer
    generic map (
        Nbits => Nbits
    )
    port map (
        clock => clock,
        reset => reset,
        enable => enable,
        max_value => max_value,
        count => count
    );
pulser: timer_pulser
    generic map (
        Nbits => Nbits
    )
    port map (
        clock => clock,
        reset => reset,
        count => count,
        trigger_only_wraparound => trigger_only_wraparound,
        trigger => trigger
    );
end compositional;
