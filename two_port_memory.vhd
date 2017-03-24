library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity two_port_memory is
    port(
        clock : in std_logic;
        wenable : in std_logic;-- write enable
        renable : in std_logic;-- output enable
        waddress : in std_logic_vector(7 downto 0);
        raddress : in std_logic_vector(7 downto 0);
        data_in : in std_logic_vector(7 downto 0);
        data_out : out std_logic_vector(7 downto 0));
end two_port_memory;

architecture behavioral of two_port_memory is
    type mem_array is array (0 to 2**(waddress'length) - 1)
    of std_logic_vector (7 downto 0);
begin
    write_read: process(clock)
        variable mem_v : mem_array;
    begin
        if renable = '1' then
            data_out <= mem_v(to_integer(unsigned(raddress)));
        else
            data_out <= (others => 'X');
        end if;

        if wenable = '1' then
            mem_v(to_integer(unsigned(waddress))) := data_in;
        end if;
    end process;
end behavioral;
