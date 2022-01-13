library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

-- Only outputs a pulse every "prescale" pulses
-- Caveat: if you just put a constant high signal, it will turn it into a pulse every N clocks
entity pulse_prescaler is
    generic(Nbits: integer := 10); -- N bits to use for pulse counter
    port(
        clock : in std_logic;
        reset : in std_logic;
        prescale : in std_logic_vector(Nbits - 1 downto 0);
        sig_in : in std_logic;
        sig_out : out std_logic
        );
end;

architecture behavioral of pulse_prescaler is
    signal count_reg : std_logic_vector(Nbits - 1 downto 0);
    signal next_count_reg : std_logic_vector(Nbits - 1 downto 0);
    signal count_reg_num : integer;
begin
    -- registers
    process(clock)
    begin
        if rising_edge(clock) then
            if reset = '1' then
                count_reg <= (others => '0');
            else -- not reset
                count_reg <= next_count_reg;
            end if; -- reset / not
        end if; -- rising edge clock
    end process;
    -- bookkeeping
    count_reg_num <= to_integer(unsigned(count_reg));
    -- next state
    process(count_reg,count_reg_num,sig_in,prescale)
    begin
        if sig_in = '1' then
            if count_reg = prescale then
                next_count_reg <= (others => '0');
            else
                next_count_reg <= std_logic_vector(to_unsigned(count_reg_num + 1,Nbits));
            end if;
        else
            next_count_reg <= count_reg;
        end if;
    end process;
    -- output
    sig_out <= '1' when count_reg_num = 0 and sig_in = '1' else '0';
end behavioral;
