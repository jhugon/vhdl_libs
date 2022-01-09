library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library vunit_lib;
context vunit_lib.vunit_context;

entity tb_two_port_memory is
  generic (runner_cfg : string);
end entity;

architecture tb of tb_two_port_memory is
    signal clock : std_logic := '0';
    signal wenable : std_logic := '0';
    signal renable : std_logic := '0';
    signal waddress : std_logic_vector(3 downto 0) := "0000";
    signal raddress : std_logic_vector(3 downto 0) := "0000";
    signal data_in : std_logic_vector(7 downto 0) := "00000000";
    signal data_out : std_logic_vector(7 downto 0) := "00000000";
begin
  mem : entity work.two_port_memory generic map (Ndata => 8, Naddress => 4) 
                                 port map (clock => clock,
                                    wenable => wenable, renable => renable,
                                    waddress => waddress, raddress => raddress,
                                    data_in => data_in, data_out => data_out
                                 );

  main : process
    procedure fill_up_mem is
    begin
      wenable <= '0';
      renable <= '0';
      raddress <= "0000";
      wait until rising_edge(clock);
      for i in 0 to 2**waddress'length -1 loop
        wenable <= '1';
        waddress <= std_logic_vector(to_unsigned(i,waddress'length));
        data_in <= std_logic_vector(to_unsigned(i,data_in'length));
        wait until rising_edge(clock);
      end loop;
      wenable <= '0';
      renable <= '0';
    end procedure fill_up_mem;
    procedure read_out_mem is
    begin
      wenable <= '0';
      renable <= '0';
      waddress <= "0000";
      raddress <= "0000";
      renable <= '1';
      wait until rising_edge(clock);
      for i in 0 to 2**waddress'length -1 loop
        renable <= '1';
        if i < 2**waddress'length-1 then
          raddress <= std_logic_vector(to_unsigned(i+1,waddress'length));
        end if;
        wait until rising_edge(clock);
        log("Memory address " & to_string(i) & ":" & to_string(data_out));
      end loop;
      wenable <= '0';
      renable <= '0';
      waddress <= "0000";
      raddress <= "0000";
    end procedure read_out_mem;
  begin
    logger_init(display_format => level);
    --logger_init(display_format => verbose);
    --enable_pass_msg;
    test_runner_setup(runner, runner_cfg);

    while test_suite loop

      if run("fill_up_mem") then
        fill_up_mem;
      elsif run("fill_up_mem_read_out") then
        fill_up_mem;
        read_out_mem;
      end if;
    end loop;

    test_runner_cleanup(runner);
  end process;

  clock <= not clock after 25 ns;
  test_runner_watchdog(runner, 1 ms);
end architecture;
