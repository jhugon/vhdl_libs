library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library vunit_lib;
context vunit_lib.vunit_context;
use vunit_lib.log_types_pkg.all;
use vunit_lib.log_special_types_pkg.all;
use vunit_lib.log_pkg.all;

entity circular_buffer is
    generic(Ndata : integer; -- data word bit width
            Naddress : integer); -- address word bit width
    port(
        clock : in std_logic;
        wenable : in std_logic; -- write enable
        renable : in std_logic; -- output enable
        data_in : in std_logic_vector(Ndata - 1 downto 0);
        data_out : out std_logic_vector(Ndata - 1 downto 0);
        full : out std_logic;
        empty : out std_logic);
end circular_buffer;

architecture behavioral of circular_buffer is
    signal waddress : std_logic_vector(Naddress - 1 downto 0);
    signal raddress : std_logic_vector(Naddress - 1 downto 0);
begin
    mem : entity work.two_port_memory generic map (Ndata => Ndata, Naddress => Naddress) 
                                 port map (clock => clock,
                                    wenable => wenable, renable => renable,
                                    waddress => waddress, raddress => raddress,
                                    data_in => data_in, data_out => data_out
                                 );
    fsm: process(clock)
    begin
        if rising_edge(clock) then
            -- stuff ....
        end if; -- rising edge clock
    end process;
end behavioral;
