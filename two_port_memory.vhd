library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library vunit_lib;
context vunit_lib.vunit_context;

entity two_port_memory is
    generic(Ndata : integer; -- data word bit width
            Naddress : integer); -- address word bit width
    port(
        clock : in std_logic;
        wenable : in std_logic;-- write enable
        renable : in std_logic;-- output enable
        waddress : in std_logic_vector(Naddress - 1 downto 0);
        raddress : in std_logic_vector(Naddress - 1 downto 0);
        data_in : in std_logic_vector(Ndata - 1 downto 0);
        data_out : out std_logic_vector(Ndata - 1 downto 0));
end two_port_memory;

architecture behavioral of two_port_memory is
    type mem_array is array (0 to 2**(Naddress) - 1)
    of std_logic_vector (7 downto 0);
begin
    write_read: process(clock)
        variable mem_v : mem_array;
    begin
        if rising_edge(clock) then
            if renable = '1' then
                data_out <= mem_v(to_integer(unsigned(raddress)));
            else
                data_out <= (others => 'X');
            end if;

            if wenable = '1' then
                mem_v(to_integer(unsigned(waddress))) := data_in;
            end if;
--            log("Two port memory at end of process:");
--            log("wenable: " & to_string(wenable) & " renable: " & to_string(renable));
--            log("waddress: " & to_string(waddress) & " raddress: " & to_string(raddress));
--            log("data_in: " & to_string(data_in) & " data_out: " & to_string(data_out));
--            for i in 0 to 2**waddress'length -1 loop
--              log(to_string(mem_v(i)));
--            end loop;
        end if; -- rising edge clock
    end process;
end behavioral;
