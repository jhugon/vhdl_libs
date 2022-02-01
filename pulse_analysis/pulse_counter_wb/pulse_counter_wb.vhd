library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

-- Pulse Counter Wishbone Core
-- 
-- Wishbone information:

-- Wishbone B4 Classic Slave
-- Signals are similar to the WB B spec with a "wb_" prefix.
-- Wishbone port size and granularity are 32 bits
-- Operand size 32 bit (N/A)
-- Big endian/little endian
-- Data transfer ordering: undefined
-- No constraints on clk_i
-- 
-- Since granularity is 32 bits, wb_addr_i should be bit 2 (indexing from 0) of the address.
--
-- Register information:
--
-- There are 2 registers:
--
-- wb_adr_i = 0 is read only and the current count (32 bits wide)
-- wb_adr_i = 1 is the control/status register. Bit 0 is enable, bit 1 is reset.
--
entity pulse_counter_wb is
    port(
        sig_in : in std_logic;
        wb_clk_i : in std_logic;
        wb_rst_i : in std_logic;
        wb_cyc_i : in std_logic;
        wb_adr_i : in std_logic; -- 1 bit address space
        wb_stb_i : in std_logic;
        wb_we_i : in std_logic;
        wb_dat_i : in std_logic_vector(31 downto 0);
        wb_ack_o : out std_logic;
        wb_dat_o : out std_logic_vector(31 downto 0)
        );
end;

architecture behavioral of pulse_counter_wb is
    component pulse_counter is
        generic(Nbits: integer := 10); -- size of counter
        port(
            clock : in std_logic;
            reset : in std_logic;
            enable : in std_logic;
            sig_in : in std_logic;
            count : out std_logic_vector(Nbits -1 downto 0)
            );
    end component;
    signal enable_reg : std_logic;
    signal enable_next : std_logic;
    signal reset_reg : std_logic;
    signal reset_next : std_logic;
    signal count : std_logic_vector(31 downto 0);
    signal actually_reset : std_logic;
begin
    pls_counter : pulse_counter 
        generic map (Nbits => 32)
        port map (
            clock => wb_clk_i,
            reset => actually_reset,
            enable => enable_reg,
            count => count,
            sig_in => sig_in
        );
    -- registers
    reg_proc : process(wb_clk_i)
    begin
        if rising_edge(wb_clk_i) then
            if actually_reset = '1' then
                enable_reg <= '0';
                reset_reg <= '0';
            else
                enable_reg <= enable_next;
                reset_reg <= reset_next;
            end if;
        end if;
    end process;
    -- next state
    next_state_proc : process(wb_stb_i,wb_we_i,wb_adr_i,wb_dat_i,wb_rst_i,enable_reg,count,reset_reg)
    begin
        if wb_stb_i = '1' then
            if wb_we_i = '1' then
                wb_dat_o <= (others => '0');
                if wb_adr_i = '1' then -- CSR
                    enable_next <= wb_dat_i(0);
                    reset_next <= wb_dat_i(1);
                else -- count register
                    enable_next <= enable_reg;
                    reset_next <= reset_reg;
                end if;
            else
                enable_next <= enable_reg;
                reset_next <= reset_reg;
                if wb_adr_i = '1' then -- CSR
                    wb_dat_o <= (0 => enable_reg, 1 => reset_reg, others => '0');
                else -- count register
                    wb_dat_o <= count;
                end if;
            end if;
        else
            enable_next <= enable_reg;
            reset_next <= reset_reg;
            wb_dat_o <= (others => '0');
        end if;
    end process;
    actually_reset <= reset_reg or wb_rst_i;
    -- output
    wb_ack_o <= wb_stb_i;
end behavioral;
