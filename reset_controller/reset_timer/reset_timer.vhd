library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Holds reset high for "count_to_reset" clock cycles
-- 
entity reset_timer is
    generic(Nbits: integer := 4); -- N bits to use for counter
    port(
        clock : in std_logic;
        count_to_reset : in std_logic_vector(Nbits - 1 downto 0);
        reset : out std_logic
    );
end reset_timer;

architecture behavioral of reset_timer is
    signal count_reg : std_logic_vector(Nbits - 1 downto 0) := (others => '0');
    signal reset_reg : std_logic := '1';
    signal count_next : std_logic_vector(Nbits - 1 downto 0);
    signal reset_next : std_logic;
    signal count_num : integer;
    signal count_to_reset_num : integer;
begin
    -- registers
    process(clock)
    begin
        if rising_edge(clock) then
            count_reg <= count_next;
            reset_reg <= reset_next;
        end if;
    end process;
    -- bookkeeping
    count_num <= to_integer(unsigned(count_reg));
    count_to_reset_num <= to_integer(unsigned(count_to_reset));
    -- next state
    count_next <= std_logic_vector(to_unsigned(to_integer(unsigned(count_reg))+1,Nbits));
    process(reset_reg,count_num,count_to_reset_num)
    begin
        if reset_reg = '0' then
            reset_next <= '0';
        else
            if count_num < count_to_reset_num then
                reset_next <= '1';
            else
                reset_next <= '0';
            end if;
        end if;
    end process;
    -- output
    reset <= reset_reg;
end behavioral;
