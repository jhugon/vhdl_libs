library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity output_compare is
    generic(Nbits: integer := 10; -- should be the same as the counter
            use_ff: integer := 0); -- set to 1 to use a ff, otherwise all combinatorial
    port(
        clock : in std_logic;
        compare : in std_logic_vector(Nbits - 1 downto 0);
        count : in std_logic_vector(Nbits - 1 downto 0);
        matched : out std_logic
        );
end;

architecture behavioral of output_compare is
    signal count_num : unsigned(Nbits - 1 downto 0);
    signal compare_num : unsigned(Nbits - 1 downto 0);
    -- only used if use_ff > 0
    signal matched_reg : std_logic;
    signal next_matched_reg : std_logic;
begin
    -- bookkeeping
    compare_num <= unsigned(compare);
    count_num <= unsigned(count);

    output_comb: if use_ff = 0 generate
        -- output
        matched <= '1' when count_num >= compare_num else '0';
    end generate output_comb;

    output_ff: if use_ff > 0 generate
        -- register
        process(clock)
        begin
            if rising_edge(clock) then
                matched_reg <= next_matched_reg;
            end if; -- rising edge clock
        end process;
        -- next state
        next_matched_reg <= '1' when count_num >= compare_num else '0';
        -- output
        matched <= matched_reg;
    end generate output_ff;
end behavioral;
