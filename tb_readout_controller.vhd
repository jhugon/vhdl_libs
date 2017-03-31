library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library vunit_lib;
context vunit_lib.vunit_context;
use vunit_lib.log_types_pkg.all;
use vunit_lib.log_special_types_pkg.all;
use vunit_lib.log_pkg.all;

entity tb_readout_controller is
  generic (runner_cfg : string);
end entity;

architecture tb of tb_readout_controller is
    signal clock : std_logic := '0';
    signal reset : std_logic := '0';
    signal wenable : std_logic := '0';
    signal renable : std_logic := '0';
    signal full : std_logic := '0';
    signal empty : std_logic := '0';
    signal dead : std_logic := '0';
    signal trigger : std_logic := '0';
begin
  cbc : entity work.readout_controller port map (clock => clock, reset => reset,
                                    wenable => wenable, renable => renable,
                                    full => full, empty => empty,
                                    dead => dead, trigger => trigger
                                 );
  main : process
    procedure reset_entity is
    begin
        full <= '0';
        empty <= '0';
        trigger <= '0';
        reset <= '1';
        wait for 50 ns; -- check reset
        reset <= '0';
    end procedure reset_entity;
    procedure do_nothing is
    begin
        wait for 50 ns; -- check reset
    end procedure do_nothing;
  begin
    logger_init(display_format => level);
    --logger_init(display_format => verbose);
    --checker_init(display_format => level);
    checker_init(display_format => verbose);
    --enable_pass_msg;
    test_runner_setup(runner, runner_cfg);

    while test_suite loop

      if run("reset") then
        reset_entity;
        check_equal(dead,true,"dead");
        check_equal(wenable,true,"wenable");
        check_equal(renable,false,"renable");
        do_nothing;
        check_equal(dead,true,"dead");
        check_equal(wenable,true,"wenable");
        check_equal(renable,false,"renable");
        do_nothing;
        check_equal(dead,true,"dead");
        check_equal(wenable,true,"wenable");
        check_equal(renable,false,"renable");
        do_nothing;
        check_equal(dead,true,"dead");
        check_equal(wenable,true,"wenable");
        check_equal(renable,false,"renable");
        do_nothing;
        check_equal(dead,true,"dead");
        check_equal(wenable,true,"wenable");
        check_equal(renable,false,"renable");
      elsif run("full_then_trigger_then_empty_then_reset") then
        reset_entity;
        check_equal(dead,true,"dead");
        check_equal(wenable,true,"wenable");
        check_equal(renable,false,"renable");
        full <= '1';
        do_nothing;
        check_equal(dead,false,"dead");
        check_equal(wenable,true,"wenable");
        check_equal(renable,false,"renable");
        do_nothing;
        check_equal(dead,false,"dead");
        check_equal(wenable,true,"wenable");
        check_equal(renable,false,"renable");
        trigger <= '1';
        do_nothing;
        check_equal(dead,true,"dead");
        check_equal(wenable,false,"wenable");
        check_equal(renable,true,"renable");
        trigger <= '0';
        full <= '0';
        do_nothing;
        check_equal(dead,true,"dead");
        check_equal(wenable,false,"wenable");
        check_equal(renable,true,"renable");
        empty <= '1';
        do_nothing;
        check_equal(dead,true,"dead");
        check_equal(wenable,true,"wenable");
        check_equal(renable,false,"renable");
        do_nothing;
        check_equal(dead,true,"dead");
        check_equal(wenable,true,"wenable");
        check_equal(renable,false,"renable");
        reset_entity;
        check_equal(dead,true,"dead");
        check_equal(wenable,true,"wenable");
        check_equal(renable,false,"renable");
        do_nothing;
        check_equal(dead,true,"dead");
        check_equal(wenable,true,"wenable");
        check_equal(renable,false,"renable");
      elsif run("full_then_trigger_then_empty_then_reset_onecycle") then
        reset_entity;
        check_equal(dead,true,"dead");
        check_equal(wenable,true,"wenable");
        check_equal(renable,false,"renable");
        full <= '1';
        do_nothing;
        check_equal(dead,false,"dead");
        check_equal(wenable,true,"wenable");
        check_equal(renable,false,"renable");
        trigger <= '1';
        do_nothing;
        check_equal(dead,true,"dead");
        check_equal(wenable,false,"wenable");
        check_equal(renable,true,"renable");
        trigger <= '0';
        full <= '0';
        empty <= '1';
        do_nothing;
        check_equal(dead,true,"dead");
        check_equal(wenable,true,"wenable");
        check_equal(renable,false,"renable");
        reset_entity;
        check_equal(dead,true,"dead");
        check_equal(wenable,true,"wenable");
        check_equal(renable,false,"renable");
        do_nothing;
        check_equal(dead,true,"dead");
        check_equal(wenable,true,"wenable");
        check_equal(renable,false,"renable");
      elsif run("full_then_trigger_then_reset") then
        reset_entity;
        check_equal(dead,true,"dead");
        check_equal(wenable,true,"wenable");
        check_equal(renable,false,"renable");
        full <= '1';
        do_nothing;
        check_equal(dead,false,"dead");
        check_equal(wenable,true,"wenable");
        check_equal(renable,false,"renable");
        do_nothing;
        check_equal(dead,false,"dead");
        check_equal(wenable,true,"wenable");
        check_equal(renable,false,"renable");
        trigger <= '1';
        do_nothing;
        check_equal(dead,true,"dead");
        check_equal(wenable,false,"wenable");
        check_equal(renable,true,"renable");
        trigger <= '0';
        full <= '0';
        do_nothing;
        check_equal(dead,true,"dead");
        check_equal(wenable,false,"wenable");
        check_equal(renable,true,"renable");
        reset_entity;
        check_equal(dead,true,"dead");
        check_equal(wenable,true,"wenable");
        check_equal(renable,false,"renable");
        do_nothing;
        check_equal(dead,true,"dead");
        check_equal(wenable,true,"wenable");
        check_equal(renable,false,"renable");
      elsif run("full_then_reset") then
        reset_entity;
        check_equal(dead,true,"dead");
        check_equal(wenable,true,"wenable");
        check_equal(renable,false,"renable");
        full <= '1';
        do_nothing;
        check_equal(dead,false,"dead");
        check_equal(wenable,true,"wenable");
        check_equal(renable,false,"renable");
        do_nothing;
        check_equal(dead,false,"dead");
        check_equal(wenable,true,"wenable");
        check_equal(renable,false,"renable");
        reset_entity;
        check_equal(dead,true,"dead");
        check_equal(wenable,true,"wenable");
        check_equal(renable,false,"renable");
        do_nothing;
        check_equal(dead,true,"dead");
        check_equal(wenable,true,"wenable");
        check_equal(renable,false,"renable");
      end if;
    end loop;

    test_runner_cleanup(runner);
  end process;

  clock <= not clock after 25 ns;
  test_runner_watchdog(runner, 1 ms);
end architecture;
