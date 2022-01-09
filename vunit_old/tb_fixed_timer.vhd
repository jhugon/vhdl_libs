library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library vunit_lib;
context vunit_lib.vunit_context;

entity tb_fixed_timer is
  generic (runner_cfg : string);
end entity;

architecture tb of tb_fixed_timer is
    signal clock : std_logic := '0';
    signal reset : std_logic := '0';
    signal enable : std_logic := '0';
    signal trigger : std_logic := '0';
    signal triggermax : std_logic := '0';
begin
  ft : entity work.fixed_timer generic map (interval => 4) 
                                 port map (clock => clock, reset => reset,
                                    enable => enable,
                                    trigger => trigger
                                 );
  ftmax : entity work.fixed_timer generic map (interval => 15) 
                                 port map (clock => clock, reset => reset,
                                    enable => enable,
                                    trigger => triggermax
                                 );
  main : process
    procedure reset_ft is
    begin
        enable <= '0';
        reset <= '1';
        wait for 50 ns; -- check reset
        reset <= '0';
    end procedure reset_ft;
    procedure enable_once is
    begin
        enable <= '1';
        wait for 50 ns;
        enable <= '0';
    end procedure enable_once;
    procedure not_enable_once is
    begin
        enable <= '0';
        wait for 50 ns;
    end procedure not_enable_once;
  begin
    logger_init(display_format => level);
    --logger_init(display_format => verbose);
    --checker_init(display_format => level);
    checker_init(display_format => verbose);
    --enable_pass_msg;
    test_runner_setup(runner, runner_cfg);

    while test_suite loop

      if run("not_enabled") then
        reset_ft;
        check_equal(trigger,'0',"trigger start");
        check_equal(triggermax,'0',"triggermax start");
        for i in 0 to 100 loop
            not_enable_once;
            check_equal(trigger,'0',"trigger continue");
            check_equal(triggermax,'0',"triggermax continue");
        end loop;
      elsif run("enabled") then
        reset_ft;
        check_equal(trigger,'0',"trigger start");
        check_equal(triggermax,'0',"triggermax start");
        for i in 1 to 200 loop
            log("i: " & to_string(i));
            log("trigger before: " & to_string(trigger));
            enable_once;
            log("trigger after: " & to_string(trigger));
            check_equal(trigger,(i mod 4) = 0,"trigger continue");
            check_equal(triggermax,(i mod 15) = 0,"triggermax continue");
        end loop;
      end if;
    end loop;

    test_runner_cleanup(runner);
  end process;

  clock <= not clock after 25 ns;
  test_runner_watchdog(runner, 1 ms);
end architecture;
