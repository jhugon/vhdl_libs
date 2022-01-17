library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

-- On the first clock that sig_in is high, match_count is set to count and
-- matched is made high. You must reset input_compare to be able to match again.
-- enable can be used to wait until some event (like another input_compare) before enabling capture
entity input_compare is
    generic(Nbits: integer := 10); -- should be the same as the counter
    port(
        clock : in std_logic;
        reset : in std_logic;
        enable : in std_logic;
        count : in std_logic_vector(Nbits - 1 downto 0);
        sig_in : in std_logic;
        matched : out std_logic;
        match_count : out std_logic_vector(Nbits - 1 downto 0) -- only valid when matched high
        );
end;

architecture behavioral of input_compare is
    signal match_count_reg : std_logic_vector(Nbits - 1 downto 0);
    signal next_match_count_reg : std_logic_vector(Nbits - 1 downto 0);
    signal matched_reg : std_logic;
    signal next_matched_reg : std_logic;
begin
    -- registers
    process(clock)
    begin
        if rising_edge(clock) then
            if reset = '1' then
                -- don't need to reset match_count_reg, output invalid until matched high
                -- match_count_reg <= (others => '0');
                matched_reg <= '0';
            else -- not reset
                match_count_reg <= next_match_count_reg;
                matched_reg <= next_matched_reg;
            end if; -- reset / not
        end if; -- rising edge clock
    end process;
    -- next state
    -- process(sig_in,matched_reg,match_count_reg,count)
    -- begin
    --     if matched_reg = '1' then
    --         next_matched_reg <= matched_reg;
    --         next_match_count_reg <= match_count_reg;
    --     else
    --         if sig_in = '1' then
    --             next_matched_reg <= '1';
    --             next_match_count_reg <= count;
    --         else
    --             next_matched_reg <= matched_reg;
    --             next_match_count_reg <= match_count_reg;
    --         end if;
    --     end if;
    -- end process;
    -- equiv to above
    next_matched_reg <= '1' when (matched_reg = '0') and (sig_in = '1') else matched_reg;
    next_match_count_reg <= count when (matched_reg = '0') and (sig_in = '1') else match_count_reg;
    -- output
    matched <= matched_reg;
    match_count <= match_count_reg;
end behavioral;
