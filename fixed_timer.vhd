library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library vunit_lib;
context vunit_lib.vunit_context;
use vunit_lib.log_types_pkg.all;
use vunit_lib.log_special_types_pkg.all;
use vunit_lib.log_pkg.all;

entity fixed_timer is
    generic(Ndata : integer; -- register size in bits
            interval: integer); -- register interval
    port(
        clock : in std_logic;
        reset : in std_logic;
        enable : in std_logic;
        trigger : out std_logic);
end fixed_timer;

architecture behavioral of fixed_timer is
    signal reg : std_logic_vector(Ndata - 1 downto 0);
    signal reg_next : std_logic_vector(Ndata - 1 downto 0);
begin
    -- registers
    process(clock)
    begin
        if rising_edge(clock) then
            log("fixed timer register updating...");
            log("reg: " & to_string(reg) & " reg_next: " & to_string(reg_next) & " reset: " & to_string(reset));
            if reset then
                reg <= (others => '0');
            else -- not reset
                reg <= reg_next;
            end if; -- reset / not
        end if; -- rising edge clock
    end process;
    -- next state
    process(enable,reg)
      variable reg_num : unsigned(Ndata - 1 downto 0);
    begin
        reg_num := unsigned(reg);
        if enable = '1' then
            if reg_num = to_unsigned(interval-1,reg_num'length) then -- stop time
                reg_num := to_unsigned(0,reg_num'length);
            else -- not stop time
                reg_num := reg_num + 1;
            end if; -- if reg = stop
        end if; -- enable ifs
        reg_next <= std_logic_vector(reg_num);
    end process;
    -- output
    trigger <= '1' when ((reg = std_logic_vector(to_unsigned(0,reg'length))) and (enable = '1')) else '0';
end behavioral;
