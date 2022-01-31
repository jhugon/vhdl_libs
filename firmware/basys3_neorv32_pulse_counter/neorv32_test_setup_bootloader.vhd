library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library neorv32;
use neorv32.neorv32_package.all;

-- pulse counter base address is 0x71000000
entity neorv32_test_setup_bootloader is
  generic (
    -- adapt these for your setup --
    CLOCK_FREQUENCY   : natural := 100000000; -- clock frequency of clk_i in Hz
    MEM_INT_IMEM_SIZE : natural := 16*1024;   -- size of processor-internal instruction memory in bytes
    MEM_INT_DMEM_SIZE : natural := 8*1024;     -- size of processor-internal data memory in bytes
    DEBOUNCE_TICK_FREQ: integer := 100 -- in Hz
  );
  port (
    -- Global control --
    clk       : in  std_ulogic; -- global clock, rising edge
    rstn_i      : in  std_ulogic; -- global reset, low-active, async
    sw : in std_ulogic_vector(15 downto 1); -- notice 0 is missing (it's rstn_i)
    -- GPIO --
    led      : out std_ulogic_vector(15 downto 0); -- parallel output
    -- UART0 --
    RsTx : out std_ulogic; -- UART0 send data
    RsRx : in  std_ulogic; -- UART0 receive data
    -- UART1 --
    UART1_tx : out std_ulogic;
    UART1_rx : in  std_ulogic;
    -- buttons
    btnC : in std_logic
  );
end entity;

architecture neorv32_test_setup_bootloader_rtl of neorv32_test_setup_bootloader is
    component pulse_counter_wb is
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
    end component;
    component switch_input is
        port(
            clock : in std_logic;
            reset : in std_logic;
            reset_value : in std_logic;
            tick: in std_logic;
            sig_in : in std_logic;
            sig_out : out std_logic;
            falling_edge_pulse : out std_logic;
            rising_edge_pulse : out std_logic
            );
    end component;
    component programmable_timer_pulser is
        generic(Nbits: integer := 10); -- N bits to use for counter
        port(
            clock : in std_logic;
            reset : in std_logic;
            enable : in std_logic;
            max_value : in std_logic_vector(Nbits - 1 downto 0);
            trigger_only_wraparound : in std_logic;
            count : out std_logic_vector(Nbits - 1 downto 0);
            trigger : out std_logic
        );
    end component;

    signal con_gpio_i : std_ulogic_vector(63 downto 0);
    signal con_gpio_o : std_ulogic_vector(63 downto 0);

    -- external wishbone bus interface
    signal wb_adr_o : std_ulogic_vector(31 downto 0); -- address
    signal wb_dat_i : std_ulogic_vector(31 downto 0); -- read data
    signal wb_dat_o : std_ulogic_vector(31 downto 0); -- write data
    signal wb_we_o  : std_ulogic; -- read/write
    signal wb_sel_o : std_ulogic_vector(03 downto 0); -- byte enable
    signal wb_stb_o : std_ulogic; -- strobe
    signal wb_cyc_o : std_ulogic; -- valid cycle
    signal wb_ack_i : std_ulogic; -- transfer acknowledge

    -- pulse counter wisbone lines
    constant pulse_counter_address_base : unsigned(31 downto 0) := to_unsigned(16#71000000#,32);
    signal pc_wb_cyc : std_ulogic; -- valid cycle
    signal pc_wb_ack : std_ulogic; -- transfer acknowledge
    signal pc_wb_stb : std_ulogic; -- strobe
    signal wb_dat_o_sl : std_logic_vector(31 downto 0);
    signal wb_dat_i_sl : std_logic_vector(31 downto 0);

    -- debouncer stuff
    constant debounce_timer_max_int : integer := CLOCK_FREQUENCY/DEBOUNCE_TICK_FREQ;
    constant debounce_timer_max_nbits : integer := integer(ceil(log2(real(debounce_timer_max_int+1))));
    constant debounce_timer_max : unsigned(debounce_timer_max_nbits-1 downto 0) := to_unsigned(debounce_timer_max_int,debounce_timer_max_nbits);
    signal debounce_tick : std_ulogic;
    signal pulse_in : std_ulogic;

begin

  neorv32_top_inst: neorv32_top
  generic map (
    -- General --
    CLOCK_FREQUENCY              => CLOCK_FREQUENCY,   -- clock frequency of clk_i in Hz
    INT_BOOTLOADER_EN            => true,              -- boot configuration: true = boot explicit bootloader; false = boot from int/ext (I)MEM
    -- RISC-V CPU Extensions --
    CPU_EXTENSION_RISCV_C        => true,              -- implement compressed extension?
    CPU_EXTENSION_RISCV_M        => true,              -- implement mul/div extension?
    CPU_EXTENSION_RISCV_Zicsr    => true,              -- implement CSR system?
    CPU_EXTENSION_RISCV_Zicntr   => true,              -- implement base counters?
    -- Internal Instruction memory --
    MEM_INT_IMEM_EN              => true,              -- implement processor-internal instruction memory
    MEM_INT_IMEM_SIZE            => MEM_INT_IMEM_SIZE, -- size of processor-internal instruction memory in bytes
    -- Internal Data memory --
    MEM_INT_DMEM_EN              => true,              -- implement processor-internal data memory
    MEM_INT_DMEM_SIZE            => MEM_INT_DMEM_SIZE, -- size of processor-internal data memory in bytes
    -- External wishbone interface
    MEM_EXT_EN                   => true,
    -- Processor peripherals --
    IO_GPIO_EN                   => true,              -- implement general purpose input/output port unit (GPIO)?
    IO_MTIME_EN                  => true,              -- implement machine system timer (MTIME)?
    IO_UART0_EN                  => true,              -- implement primary universal asynchronous receiver/transmitter (UART0)?
    IO_UART1_EN                  => true,              -- implement primary universal asynchronous receiver/transmitter (UART1)?
    IO_UART1_RX_FIFO             => 8,                 -- add some extra to the fifo so that we don't need interrupts
    IO_UART1_TX_FIFO             => 8                  -- add some extra to the fifo so that we don't need interrupts
  )
  port map (
    -- Global control --
    clk_i       => clk,       -- global clock, rising edge
    rstn_i      => rstn_i,      -- global reset, low-active, async
    -- GPIO (available if IO_GPIO_EN = true) --
    gpio_i      => con_gpio_i,  -- parallel input
    gpio_o      => con_gpio_o,  -- parallel output
    -- primary UART0 (available if IO_UART0_EN = true) --
    uart0_txd_o => RsTx, -- UART0 send data
    uart0_rxd_i => RsRx, -- UART0 receive data
    uart1_txd_o => UART1_tx, -- UART1 send data
    uart1_rxd_i => UART1_rx,  -- UART1 receive data
    -- external memory interface: Wishbone Classic
    wb_adr_o => wb_adr_o,
    wb_dat_i => wb_dat_i,
    wb_dat_o => wb_dat_o,
    wb_we_o  => wb_we_o,
    wb_sel_o => wb_sel_o,
    wb_stb_o => wb_stb_o,
    wb_cyc_o => wb_cyc_o,
    wb_ack_i => wb_ack_i
  );

  pulse_counter_wb_inst : pulse_counter_wb
    port map(
        sig_in => pulse_in,
        wb_clk_i => clk,
        wb_rst_i => '0',
        wb_cyc_i => pc_wb_cyc,
        wb_adr_i => wb_adr_o(0),
        wb_stb_i => pc_wb_stb,
        wb_we_i => wb_we_o,
        wb_dat_i => wb_dat_o_sl,
        wb_ack_o => pc_wb_ack,
        wb_dat_o => wb_dat_i_sl
        );

  switch_input_inst : switch_input
    port map(
        clock => clk,
        reset => '0',
        reset_value => '0',
        tick => debounce_tick,
        sig_in => btnC,
        rising_edge_pulse => pulse_in
    );
  debounce_timer_pulser : programmable_timer_pulser
    generic map (Nbits => debounce_timer_max_nbits)
    port map (
        clock => clk,
        reset => '0',
        enable => '1',
        max_value => std_logic_vector(debounce_timer_max),
        trigger_only_wraparound => '0',
        trigger => debounce_tick
    );

  -- Wishbone multiplexer
  wb_mux : process(wb_adr_o,wb_cyc_o,pc_wb_ack,wb_stb_o)
  begin
    if unsigned(wb_adr_o(31 downto 1)) = pulse_counter_address_base(31 downto 1) then
        pc_wb_cyc <= wb_cyc_o;
        wb_ack_i <= pc_wb_ack;
        pc_wb_stb <= wb_stb_o;
    else
        pc_wb_cyc <= '0';
        wb_ack_i <= '0';
        pc_wb_stb <= '0';
    end if;
  end process;
  wb_dat_o_sl <= to_stdlogicvector(wb_dat_o);
  wb_dat_i_sl <= to_stdlogicvector(wb_dat_i);

  -- GPIO output --
  led <= con_gpio_o(15 downto 0);
  con_gpio_i <= "0000000000000000" & sw & '0' & con_gpio_o(31 downto 0);

end architecture;
