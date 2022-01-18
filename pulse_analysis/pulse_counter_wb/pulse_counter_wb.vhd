library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

-- sel_i(0) is read only and the current count
-- sel_i(1) is the control/status register. Bit 0 is enable, bit 1 is reset.
entity pulse_counter_wb is
    generic(Nbits: integer := 10; -- size of counter
            wb_width: integer := 32); -- width of wishbone data bus
    port(
        sig_in : in std_logic;
        wb_clk_i : in std_logic;
        wb_rst_i : in std_logic;
        wb_cyc_i : in std_logic;
        wb_sel_i : in std_logic_vector(1 downto 0);
        wb_stb_i : in std_logic;
        wb_we_i : in std_logic;
        wb_dat_i : in std_logic_vector(wb_width -1 downto 0);
        wb_ack_o : out std_logic;
        wb_dat_o : out std_logic_vector(wb_width -1 downto 0)
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
    signal reset : std_logic;
    signal count : std_logic_vector(Nbits -1 downto 0);
begin
    pls_counter : pulse_counter 
        generic map (Nbits => Nbits)
        port map (
            clock => wb_clk_i,
            reset => reset,
            enable => enable_reg,
            count => count,
            sig_in => sig_in
        );
    -- registers
    process(wb_clk_i)
    begin
        if rising_edge(wb_clk_i) then
            if reset = '1' then
                enable_reg <= '0';
            else
                enable_reg <= enable_next;
            end if;
        end if;
    end process;
    -- next state
    process(wb_stb_i,wb_we_i,wb_sel_i,wb_dat_i,wb_rst_i,enable_reg,count,reset)
    begin
        if wb_stb_i = '1' then
            if wb_we_i = '1' then
                wb_dat_o <= (others => '0');
                if wb_sel_i(1) = '1' then
                    enable_next <= wb_dat_i(0);
                    reset <= wb_dat_i(1) or wb_rst_i;
                else
                    enable_next <= enable_reg;
                    reset <= wb_rst_i;
                end if;
            else
                enable_next <= enable_reg;
                reset <= wb_rst_i;
                if wb_sel_i(1) = '1' then
                    wb_dat_o <= (0 => enable_reg, 1 => reset, others => '0');
                else
                    wb_dat_o <= count;
                end if;
            end if;
        else
        end if;
    end process;
    -- output
    wb_ack_o <= wb_stb_i;
end behavioral;
