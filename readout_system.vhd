library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library vunit_lib;
context vunit_lib.vunit_context;
use vunit_lib.log_types_pkg.all;
use vunit_lib.log_special_types_pkg.all;
use vunit_lib.log_pkg.all;

entity readout_system is
    generic(Ndata : integer; -- data word bit width
            Naddress : integer); -- address word bit width
    port(
        clock : in std_logic;
        reset : in std_logic;
        data_out_good : out std_logic;
        data_in : in std_logic_vector(Ndata - 1 downto 0);
        data_out : out std_logic_vector(Ndata - 1 downto 0)
        );
end readout_system;

architecture behavioral of readout_system is
    signal waddress : std_logic_vector(Naddress - 1 downto 0);
    signal raddress : std_logic_vector(Naddress - 1 downto 0);
    signal full : std_logic;
    signal empty : std_logic;
    signal trigger : std_logic;
    signal wenable : std_logic;
    signal renable : std_logic;
    signal dead : std_logic;
begin

    readout_controller_inst : entity work.readout_controller
    port map( 
        clock => clock,
        reset => reset,
        full => full,
        empty => empty,
        trigger => trigger,
        wenable => wenable,
        renable => renable,
        dead => dead
    );

    circular_buffer_controller_inst : entity work.circular_buffer_controller
    generic map (Ndata => Ndata,
                 Naddress => Naddress)
    port map( 
        clock => clock,
        reset => reset,
        wenable => wenable,
        renable => renable,
        full => full,
        empty => empty,
        waddress => waddress,
        raddress => raddress
    );

    two_port_memory_inst : entity work.two_port_memory
    generic map (Ndata => Ndata,
                 Naddress => Naddress)
    port map( 
        clock => clock,
        wenable => wenable,
        renable => renable,
        waddress => waddress,
        raddress => raddress,
        data_in => data_in,
        data_out => data_out
    );

    fixed_timer_inst : entity work.fixed_timer
    generic map (Ndata => 10,
                 interval => 1000)
    port map( 
        clock => clock,
        reset => reset,
        enable => '1',
        trigger => trigger
    );

    data_out_good <= '0' when empty = '1' else '1';

end behavioral;
