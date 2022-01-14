library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

-- TICKPRESCALE: want 256 Hz from 100 MHz so 390625-1, make it smaller for sim testing
entity top is
    generic(LED_PORT_WIDTH: integer := 16;
            TICKPRESCALE: integer := 390624);
    port(clk : in std_logic;
        led : out std_logic_vector(LED_PORT_WIDTH-1 downto 0));
end;

architecture behavioral of top is
    component reset_timer is
        generic(Nbits: integer := 4); -- N bits to use for counter
        port(
            clock : in std_logic;
            count_to_reset : in std_logic_vector(Nbits - 1 downto 0);
            reset : out std_logic
        );
    end component;
    component simple_timer is
        generic(Nbits: integer := 10); -- N bits to use for counter
        port(
            clock : in std_logic;
            reset : in std_logic;
            enable : in std_logic;
            count : out std_logic_vector(Nbits - 1 downto 0)
        );
    end component;
    component programmable_timer_pulser is
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
    end component;
    signal count : std_logic_vector(LED_PORT_WIDTH-1 downto 0);
    signal reset : std_logic;
    signal tick : std_logic;
begin
-- submodules
timer : simple_timer
    generic map (Nbits => LED_PORT_WIDTH) 
    port map (
        clock => clk,
        reset => reset,
        enable => tick,
        count => count
    );
reset_ctrlr : reset_timer
    generic map (Nbits => 4)
    port map (
        clock => clk,
        count_to_reset => std_logic_vector(to_unsigned(15,4)),
        reset => reset
    );
prescale_timer : programmable_timer_pulser
    generic map (Nbits => 19) 
    port map (
        clock => clk,
        reset => reset,
        enable => '1',
        max_value => std_logic_vector(to_unsigned(TICKPRESCALE,19)),
        trigger_only_wraparound => '0',
        trigger => tick
    );
-- output logic
led <= count;
end behavioral;
