library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library vunit_lib;
context vunit_lib.vunit_context;
use vunit_lib.log_types_pkg.all;
use vunit_lib.log_special_types_pkg.all;
use vunit_lib.log_pkg.all;

entity tb_circular_buffer_controller is
  generic (runner_cfg : string);
end entity;

architecture tb of tb_circular_buffer_controller is
    signal clock : std_logic := '0';
    signal reset : std_logic := '0';
    signal wenable : std_logic := '0';
    signal renable : std_logic := '0';
    signal full : std_logic := '0';
    signal empty : std_logic := '0';
    signal waddress : std_logic_vector(3 downto 0) := "0000";
    signal raddress : std_logic_vector(3 downto 0) := "0000";
begin
  cbc : entity work.circular_buffer_controller generic map (Ndata => 8, Naddress => 4) 
                                 port map (clock => clock, reset => reset,
                                    wenable => wenable, renable => renable,
                                    full => full, empty => empty,
                                    waddress => waddress, raddress => raddress
                                 );
  main : process
  begin
    logger_init(display_format => level);
    --logger_init(display_format => verbose);
    --checker_init(display_format => level);
    checker_init(display_format => verbose);
    --enable_pass_msg;
    test_runner_setup(runner, runner_cfg);

    while test_suite loop

      if run("fill_once") then
        wenable <= '0';
        renable <= '0';
        reset <= '1';
        wait for 50 ns; -- check reset
        check_equal(waddress,0,"waddress start 0'd");
        check_equal(raddress,0,"raddress start 0'd");
        check_equal(full,false,"full start 0'd");
        check_equal(empty,true,"is emtpy");
        reset <= '0';
        wait for 50 ns; -- check nothing changes
        check_equal(waddress,0,"waddress start 0'd");
        check_equal(raddress,0,"raddress start 0'd");
        check_equal(full,false,"full start 0'd");
        check_equal(empty,true,"is emtpy");
        wenable <= '1';
        wait for 50 ns; -- now check fill once
        wenable <= '0';
        check_equal(raddress,0,"raddress start 0'd");
        check_equal(waddress,1,"waddress after one full clock");
        check_equal(full,false,"full start 0'd");
        check_equal(empty,false,"empty start 0'd");
        wait for 50 ns; -- now check nothing changed
        check_equal(raddress,0,"raddress start 0'd");
        check_equal(waddress,1,"waddress after one full clock");
        check_equal(full,false,"full start 0'd");
        check_equal(empty,false,"empty start 0'd");
      elsif run("fill_once_read_once") then
        wenable <= '0';
        renable <= '0';
        reset <= '1';
        wait for 50 ns; -- check reset
        check_equal(waddress,0,"waddress start 0'd");
        check_equal(raddress,0,"raddress start 0'd");
        check_equal(full,false,"full start 0'd");
        check_equal(empty,true,"is emtpy");
        reset <= '0';
        wait for 50 ns; -- check nothing changes
        check_equal(waddress,0,"waddress start 0'd");
        check_equal(raddress,0,"raddress start 0'd");
        check_equal(full,false,"full start 0'd");
        check_equal(empty,true,"is emtpy");
        wenable <= '1';
        wait for 50 ns; -- now check fill once
        wenable <= '0';
        check_equal(raddress,0,"raddress start 0'd");
        check_equal(waddress,1,"waddress after one full clock");
        check_equal(full,false,"full start 0'd");
        check_equal(empty,false,"empty start 0'd");
        renable <= '1';
        wait for 50 ns; -- now check read once
        check_equal(raddress,1,"raddress start 0'd");
        check_equal(waddress,1,"waddress after one full clock");
        check_equal(full,false,"full start 0'd");
        check_equal(empty,true,"empty start 0'd");
        renable <= '0';
        wait for 50 ns; -- now check nothing changes
        check_equal(raddress,1,"raddress start 0'd");
        check_equal(waddress,1,"waddress after one full clock");
        check_equal(full,false,"full start 0'd");
        check_equal(empty,true,"empty start 0'd");
      end if;
    end loop;

    test_runner_cleanup(runner);
  end process;

  clock <= not clock after 25 ns;
  test_runner_watchdog(runner, 1 ms);
end architecture;
