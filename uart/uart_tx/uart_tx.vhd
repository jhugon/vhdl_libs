library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity uart_tx is
    generic(clock_freq: integer := 100000000; -- in hertz
            uart_freq: integer := 9600; -- in hertz
            uart_period_n_clock : integer := clock_freq/uart_freq; -- don't mess with this
            timer_bit_width: integer := integer(ceil(log2(real(uart_period_n_clock))))*10); -- don't mess with this
    port(
        clock : in std_logic;
        reset : in std_logic;
        data_good : in std_logic; -- pulse high to latch data and start sending
        data : in std_logic_vector(7 downto 9);
        tx : out std_logic;
        sending : out std_logic -- tx in process, don't update data or put data_good high if this is high
    );
end uart_tx;

architecture behavioral of uart_tx is
    component programmable_timer is
        generic(Nbits: integer := 10); -- N bits to use for counter
        port(
            clock : in std_logic;
            reset : in std_logic;
            enable : in std_logic;
            max_value : in std_logic_vector(Nbits - 1 downto 0);
            count : out std_logic_vector(Nbits - 1 downto 0)
        );
    end component;

    signal data_reg : std_logic_vector(7 downto 0);
    signal next_data_reg : std_logic_vector(7 downto 0);
    signal sending_reg : std_logic;
    signal next_sending_reg : std_logic;
    signal tx_reg : std_logic;
    signal next_tx_reg : std_logic;

    signal timer_count : std_logic_vector(timer_bit_width-1 downto 0);
    signal timer_reset : std_logic;
    signal timer_max_value : std_logic_vector(timer_bit_width-1 downto 0) := std_logic_vector(unsigned(uart_period_n_clock));
    signal timer_enable : std_logic;
begin
    -- components
    timer : programmable_timer
        generic map(Nbits => timer_bit_width)
        port map(
            clock => clock,
            reset => timer_reset,
            enable => timer_enable,
            max_value => timer_max_value,
            count => timer_count
        );
    -- registers
    process(clock)
    begin
        if rising_edge(clock) then
            data_reg <= next_data_reg;
            sending_reg <= next_sending_reg;
        end if;
    end process;
    -- bookkeeping
    -- next state
    next_data_reg <= data when data_good = '1' and sending_reg = '0' else data_reg;
    next_sending_reg <= '0';
    next_tx_reg <= '0';
    -- output
    sending <= sending_reg;
    tx <= tx_reg;
    -- assertion
    assert timer_bit_width = integer(ceil(log2(real(clock_freq/uart_freq))))*10;
end behavioral;
