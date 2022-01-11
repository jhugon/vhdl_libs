library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity timer_pulser is
    generic(Nbits: integer := 10); -- N bits to use for counter
    port(
        clock : in std_logic;
        reset : in std_logic;
        count : in std_logic_vector(Nbits - 1 downto 0);
        trigger : out std_logic
    );
end timer_pulser;

architecture behavioral of timer_pulser is
    signal count_reg: std_logic_vector(Nbits - 1 downto 0);
    signal last_count_reg: std_logic_vector(Nbits - 1 downto 0);
    signal count_num: integer;
    signal last_count_num: integer;
begin
    -- registers
    process(clock)
    begin
        if rising_edge(clock) then
            if reset = '1' then
                count_reg <= (others => '0');
                last_count_reg <= (others => '0');
            else
                count_reg <= count;
                last_count_reg <= count_reg;
            end if;
        end if;
    end process;
    -- bookkeeping
    count_num <= to_integer(unsigned(count_reg));
    -- logic
    -- output
    trigger <= '1' when (count_num = 0) and (count_reg /= last_count_reg) else '0';
    
end behavioral;
