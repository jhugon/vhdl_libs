library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library vunit_lib;
context vunit_lib.vunit_context;
use vunit_lib.log_types_pkg.all;
use vunit_lib.log_special_types_pkg.all;
use vunit_lib.log_pkg.all;

entity readout_controller is
    port(
        clock : in std_logic;
        reset : in std_logic;
        full : in std_logic;
        empty : in std_logic;
        trigger : in std_logic;
        wenable : out std_logic; -- write enable
        renable : out std_logic; -- output enable
        dead : out std_logic); -- dead time is happening, can't accept triggers
end readout_controller;

architecture behavioral of readout_controller is
    type state_type is (state_wf, state_w, state_r);
    signal state, state_next : state_type;
begin
    -- registers
    process(clock)
    begin
        if rising_edge(clock) then
            log("readout ctr register updating...");
            log("state: " & to_string(state) & " state_next: " & to_string(state_next) );
            if reset then
                state <= state_w;
            else -- not reset
                state <= state_next;
            end if; -- reset / not
        end if; -- rising edge clock
    end process;
    -- next state
    process(state,full,empty,trigger)
    begin
        case state is
          when state_wf =>
            if trigger = '1' then
                state_next <= state_r;
            else
                state_next <= state_wf;
            end if;
          when state_w =>
            if full = '1' then
                state_next <= state_wf;
            else
                state_next <= state_w;
            end if;
          when state_r =>
            if empty = '1' then
                state_next <= state_w;
            else
                state_next <= state_r;
            end if;
        end case;
    end process;
    -- output
    process(state,full,empty,trigger)
    begin
        case state is
          when state_wf =>
            if trigger = '1' then
                wenable <= '0';
                renable <= '1';
                dead <= '1';
            else
                wenable <= '1';
                renable <= '0';
                dead <= '0';
            end if;
          when state_w =>
            if full = '1' then
                wenable <= '1';
                renable <= '0';
                dead <= '0';
            else
                wenable <= '1';
                renable <= '0';
                dead <= '1';
            end if;
          when state_r =>
            if empty = '1' then
                wenable <= '1';
                renable <= '0';
                dead <= '1';
            else
                wenable <= '0';
                renable <= '1';
                dead <= '1';
            end if;
        end case;
    end process;
    --wenable <= '1' when (state = state_w or state = state_wf) else '0';
    --renable <= '1' when (state = state_r) else '0';
    --dead <= '1' when (state = state_w or state = state_r) else '0';
end behavioral;
