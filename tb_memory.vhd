library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library vunit_lib;
context vunit_lib.vunit_context;
use vunit_lib.log_types_pkg.all;
use vunit_lib.log_special_types_pkg.all;
use vunit_lib.log_pkg.all;

entity tb_memory is
  generic (runner_cfg : string);
end entity;

architecture tb of tb_memory is
    signal clock : std_logic;
    signal wenable : std_logic;
    signal renable : std_logic;
    signal waddress : std_logic_vector(7 downto 0);
    signal raddress : std_logic_vector(7 downto 0);
    signal data_in : std_logic_vector(7 downto 0);
    signal data_out : std_logic_vector(7 downto 0);
begin
  mem : entity work.two_port_memory port map (clock => clock,
                                    wenable => wenable, renable => renable,
                                    waddress => waddress, raddress => raddress,
                                    data_in => data_in, data_out => data_out
                                 );

  main : process
  begin
    test_runner_setup(runner, runner_cfg);
    logger_init(display_format => level);
    --logger_init(display_format => verbose);

    while test_suite loop

      if run("test_pass") then
        -- enable_pass_msg;
        log("Test will pass");
        check(true,"Passing check");

      elsif run("test_fail") then
        log("Test will fail");
        check(false,"Failing check");

      end if;
    end loop;

    test_runner_cleanup(runner);
  end process;
end architecture;
