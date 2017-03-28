library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library vunit_lib;
context vunit_lib.vunit_context;
use vunit_lib.log_types_pkg.all;
use vunit_lib.log_special_types_pkg.all;
use vunit_lib.log_pkg.all;

-- ***USER'S RESPONSIBILITY TO NOT READ WHEN EMPTY***
entity circular_buffer_controller is
    generic(Ndata : integer; -- data word bit width
            Naddress : integer); -- address word bit width
    port(
        clock : in std_logic;
        reset : in std_logic;
        wenable : in std_logic; -- write enable
        renable : in std_logic; -- output enable
        full : out std_logic;
        empty : out std_logic;
        waddress : out std_logic_vector(Naddress - 1 downto 0);
        raddress : out std_logic_vector(Naddress - 1 downto 0));
end circular_buffer_controller;

architecture behavioral of circular_buffer_controller is
    signal waddress_reg : std_logic_vector(Naddress - 1 downto 0);
    signal raddress_reg : std_logic_vector(Naddress - 1 downto 0);
    signal full_reg : std_logic;
    signal waddress_next : std_logic_vector(Naddress - 1 downto 0);
    signal raddress_next : std_logic_vector(Naddress - 1 downto 0);
    signal full_next : std_logic;
begin
    -- registers
    process(clock)
    begin
        if rising_edge(clock) then
            log("circ buf ctr register updating...");
            log("waddress_reg: " & to_string(waddress_reg) & " raddress_reg: " & to_string(raddress_reg) 
                    & " full_reg: " & to_string(full_reg));
            log("reset: " & to_string(reset) & " waddress_next: " & to_string(waddress_next) 
                    & " raddress_next: " & to_string(raddress_next) & " full_next: " & to_string(full_next));
            if reset then
                waddress_reg <= (others => '0');
                raddress_reg <= (others => '0');
                full_reg <= '0';
            else -- not reset
                waddress_reg <= waddress_next;
                raddress_reg <= raddress_next;
                full_reg <= full_next;
            end if; -- reset / not
        end if; -- rising edge clock
    end process;
    -- next state
    process(wenable,renable,waddress_reg,raddress_reg,full_reg)
      variable raddress_num : unsigned(Naddress - 1 downto 0);
      variable waddress_num : unsigned(Naddress - 1 downto 0);
    begin
      raddress_num := unsigned(raddress_reg);
      waddress_num := unsigned(waddress_reg);
      if wenable and renable then
        raddress_next <= std_logic_vector(raddress_num + 1);
        waddress_next <= std_logic_vector(waddress_num + 1);
        full_next <= full_reg;
      elsif wenable then
        waddress_next <= std_logic_vector(waddress_num + 1);
        if (raddress_num = waddress_num) and (full_reg = '1') then
          raddress_next <= std_logic_vector(raddress_num + 1);
          full_next <= full_reg;
        elsif raddress_num = (waddress_num + 1) then
          raddress_next <= raddress_reg;
          full_next <= '1';
        else 
          raddress_next <= raddress_reg;
          full_next <= '0';
        end if;
      elsif renable then
        raddress_next <= std_logic_vector(raddress_num + 1);
        waddress_next <= waddress_reg;
        full_next <= '0';
      else -- not wenable or renable
        waddress_next <= waddress_reg;
        raddress_next <= raddress_reg;
        full_next <= full_reg;
      end if; -- wenable renable ifs
    end process;
    -- output
    waddress <= waddress_reg;
    raddress <= raddress_reg;
    full <= full_reg;
    empty <= '1' when ((waddress_reg = raddress_reg) and (full_reg = '0')) else '0';
end behavioral;
