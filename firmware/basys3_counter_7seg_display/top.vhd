library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

-- TICKPRESCALE: want 2 Hz from 100 MHz so 50000000-1, make it smaller for sim testing
entity top is
    generic(N_DIGITS: integer := 4;
            TICKPRESCALE: integer := 499999999);
    port(clk : in std_logic;
        seg : out std_logic_vector(6 downto 0);
        an : out std_logic_vector(N_DIGITS-1 downto 0));
end;

architecture behavioral of top is
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
    signal tick : std_logic;
begin
-- submodules
prescale_timer : programmable_timer_pulser
    generic map (Nbits => integer(ceil(log2(real(TICKPRESCALE))))) 
    port map (
        clock => clk,
        reset => '0',
        enable => '1',
        max_value => std_logic_vector(to_unsigned(TICKPRESCALE,integer(ceil(log2(real(TICKPRESCALE)))))),
        trigger_only_wraparound => '0',
        trigger => tick
    );
-- output logic
end behavioral;
