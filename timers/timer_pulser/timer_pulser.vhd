library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Hook this up next to a timer to generate a pulse when count is zero.
-- trigger_only_wraparound:
--          0: any time count is 0, will trigger. So if count is held
--             at 0, then trigger will stay high.
--          1: Only trigger when count goes from non-zero to zero.
entity timer_pulser is
    generic(Nbits: integer := 10); -- N bits to use for counter
    port(
        clock : in std_logic;
        reset : in std_logic;
        count : in std_logic_vector(Nbits - 1 downto 0);
        trigger_only_wraparound : in std_logic;
        trigger : out std_logic
    );
end timer_pulser;

architecture behavioral of timer_pulser is
    signal count_reg: std_logic_vector(Nbits - 1 downto 0);
    signal last_count_reg: std_logic_vector(Nbits - 1 downto 0);
    signal count_reg_next: std_logic_vector(Nbits - 1 downto 0);
    signal last_count_reg_next: std_logic_vector(Nbits - 1 downto 0);
    signal count_num: integer;
    signal count_reg_num: integer;
begin
    -- registers
    process(clock)
    begin
        if rising_edge(clock) then
            if reset = '1' then
                count_reg <= (others => '0');
                last_count_reg <= (others => '0');
            else
                count_reg <= count_reg_next;
                last_count_reg <= last_count_reg_next;
            end if;
        end if;
    end process;
    -- bookkeeping
    count_reg_num <= to_integer(unsigned(count_reg));
    count_num <= to_integer(unsigned(count));
    -- next state
    count_reg_next <= count;
    last_count_reg_next <= count_reg;
    -- output
    process(trigger_only_wraparound,count_num,count_reg,count_reg_num,last_count_reg)
    begin
        if trigger_only_wraparound = '1' then
            if (count_reg_num = 0) and (count_reg /= last_count_reg) then
                trigger <= '1';
            else
                trigger <= '0';
            end if;
        else -- bypasses flip-flops, so should be just comb logic if trigger_only_wraparound is hardcoded to '0'
            if count_num = 0 then
                trigger <= '1';
            else
                trigger <= '0';
            end if;
        end if;
    end process;
end behavioral;
