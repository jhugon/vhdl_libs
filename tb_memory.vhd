library vunit_lib;
context vunit_lib.vunit_context;
use vunit_lib.log_types_pkg.all;
use vunit_lib.log_special_types_pkg.all;
use vunit_lib.log_pkg.all;

entity tb_memory is
  generic (runner_cfg : string);
end entity;

architecture tb of tb_memory is
begin
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
