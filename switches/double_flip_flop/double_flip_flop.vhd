library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

-- Used to reduce metastability with asyncronous inputs or clock domain crossings
entity double_flip_flop is
    port(
        clock : in std_logic;
        reset : in std_logic;
        sig_in : in std_logic;
        sig_out : out std_logic
        );
end;

architecture behavioral of double_flip_flop is
    signal in_reg : std_logic;
    signal out_reg : std_logic;
    signal in_next : std_logic;
    signal out_next : std_logic;

    -- trying to keep these flip-flops from being optimized out
    attribute keep : boolean;
    attribute keep of in_reg : signal is true;
    attribute keep of out_reg : signal is true;
    attribute keep of in_next : signal is true;
    attribute keep of out_next : signal is true;
begin
    -- registers
    process(clock)
    begin
        if rising_edge(clock) then
            if reset = '1' then
                in_reg <= '0';
                out_reg <= '0';
            else -- not reset
                in_reg <= in_next;
                out_reg <= out_next;
            end if; -- reset / not
        end if; -- rising edge clock
    end process;
    -- next state
    in_next <= sig_in;
    out_next <= in_reg;
    -- output
    sig_out <= out_reg;
end behavioral;
