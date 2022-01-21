library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity uart_tx is
    generic(CLOCK_FREQ: integer := 100000000; -- in hertz
            UART_FREQ: integer := 9600; -- in hertz
            UART_PERIOD_N_CLOCK : integer := CLOCK_FREQ/UART_FREQ; -- don't mess with this
            TIMER_BIT_WIDTH: integer := integer(ceil(log2(real(UART_PERIOD_N_CLOCK))))); -- don't mess with this
    port(
        clock : in std_logic;
        reset : in std_logic;
        latch_in_data : in std_logic; -- pulse high to latch data and start sending
        in_data : in std_logic_vector(7 downto 0);
        tx : out std_logic;
        sending : out std_logic; -- tx in process
        ready_for_in_data : out std_logic -- data will be latched when this and latch_in_data are both high
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

    type line_state_type is (IDLE_BIT,START_BIT,DATA_BIT,STOP_BIT,STOP_BIT_DATA_LATCHED);
    signal line_state : line_state_type;
    signal next_line_state : line_state_type;

    signal data_reg : std_logic_vector(7 downto 0);
    signal next_data_reg : std_logic_vector(7 downto 0);

    signal tx_reg : std_logic;
    signal next_tx_reg : std_logic;
    signal ibit_reg : std_logic_vector(2 downto 0);
    signal next_ibit_reg : std_logic_vector(2 downto 0);

    signal timer_count : std_logic_vector(TIMER_BIT_WIDTH-1 downto 0);
    signal timer_reset : std_logic;
    constant timer_max_value : std_logic_vector(TIMER_BIT_WIDTH-1 downto 0) := std_logic_vector(to_unsigned(UART_PERIOD_N_CLOCK-1,TIMER_BIT_WIDTH));
    signal timer_enable : std_logic;
begin
    -- components
    timer : programmable_timer
        generic map(Nbits => TIMER_BIT_WIDTH)
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
            if reset then
                line_state <= IDLE_BIT;
            else
                line_state <= next_line_state;
            end if;
            -- not resettable
            data_reg <= next_data_reg;
            ibit_reg <= next_ibit_reg;
            tx_reg <= next_tx_reg;
        end if;
    end process;
    -- bookkeeping
    -- next state
    process(all)
        variable timer_max_value_int : integer;
        variable timer_count_int : integer;
        variable ibit_reg_int : integer;
    begin
        timer_max_value_int := to_integer(unsigned(timer_max_value));
        timer_count_int := to_integer(unsigned(timer_count));
        ibit_reg_int := to_integer(unsigned(ibit_reg));
        case line_state is
            when IDLE_BIT => 
                if latch_in_data then
                    next_line_state <= START_BIT;
                    next_data_reg <= in_data;
                else
                    next_line_state <= line_state;
                    next_data_reg <= data_reg;
                end if;
                next_tx_reg <= '1';
                next_ibit_reg <= 3d"0";
            when START_BIT => 
                if timer_count = timer_max_value then
                   next_line_state <= DATA_BIT;
                else
                   next_line_state <= line_state;
                end if;
                next_tx_reg <= '0';
                next_ibit_reg <= 3d"0";
                next_data_reg <= data_reg;
            when DATA_BIT => 
                if timer_count = timer_max_value then
                    -- this is the shift register
                    next_data_reg <= '0' & data_reg(data_reg'high downto data_reg'low+1);
                    if ibit_reg = 3d"7" then
                        next_line_state <= STOP_BIT;
                        next_ibit_reg <= ibit_reg;
                    else
                        next_line_state <= line_state;
                        next_ibit_reg <= std_logic_vector(to_unsigned(ibit_reg_int+1,3));
                    end if;
                else
                    next_line_state <= line_state;
                    next_ibit_reg <= ibit_reg;
                    next_data_reg <= data_reg;
                end if;
                next_tx_reg <= data_reg(data_reg'low);
            when STOP_BIT => 
                if latch_in_data = '1' and timer_count = timer_max_value then
                    next_line_state <= START_BIT;
                    next_data_reg <= in_data;
                elsif latch_in_data = '1' then
                    next_line_state <= STOP_BIT_DATA_LATCHED;
                    next_data_reg <= in_data;
                elsif timer_count = timer_max_value then
                    next_line_state <= IDLE_BIT;
                    next_data_reg <= data_reg;
                else
                    next_line_state <= line_state;
                    next_data_reg <= data_reg;
                end if;
                next_tx_reg <= '1';
                next_ibit_reg <= 3d"0";
            when STOP_BIT_DATA_LATCHED => 
                if timer_count = timer_max_value then
                   next_line_state <= START_BIT;
                else
                   next_line_state <= line_state;
                end if;
                next_tx_reg <= '1';
                next_ibit_reg <= 3d"0";
                next_data_reg <= data_reg;
        end case;
    end process;
    timer_reset <= '1' when line_state = IDLE_BIT else '0';
    timer_enable <= '1' when line_state /= IDLE_BIT else '0';
    -- output
    sending <= '1' when line_state /= IDLE_BIT else '0';
    tx <= tx_reg;
    ready_for_in_data <= '1' when (line_state = IDLE_BIT) or (line_state = STOP_BIT) else '0';
    -- assertion
    assert UART_PERIOD_N_CLOCK = CLOCK_FREQ/UART_FREQ;
    assert TIMER_BIT_WIDTH = integer(ceil(log2(real(UART_PERIOD_N_CLOCK))));
end behavioral;
