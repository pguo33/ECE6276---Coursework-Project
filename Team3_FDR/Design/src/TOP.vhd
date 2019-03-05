library ieee;
use ieee.std_logic_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity TOP is
    port ( 
            CLK         : in  std_logic;
            UART_RXD 	: in  std_logic;
            UART_TXD    : out std_logic
         );
end TOP;

architecture arch of TOP is

    -- Test Bench uses a 100 MHz Clock
    -- Want to interface to 9600 baud UART
    -- 100000000 / 9600 = 10417 Clocks Per Bit.
    constant c_CLKS_PER_BIT : integer := 10416;
    
    component uart_tx is
    generic (
      g_CLKS_PER_BIT : integer := c_CLKS_PER_BIT
      );
    port (
            i_clk       : in  std_logic;
            i_tx_dv     : in  std_logic;
            i_tx_byte   : in  std_logic_vector(7 downto 0);
            o_tx_active : out std_logic;
            o_tx_serial : out std_logic;
            o_tx_done   : out std_logic
          );
    end component uart_tx;
    
    component uart_rx is
    generic (
      g_CLKS_PER_BIT : integer := c_CLKS_PER_BIT
      );
    port (
            i_clk       : in  std_logic;
            i_rx_serial : in  std_logic;
            o_rx_dv     : out std_logic;
            o_rx_byte   : out std_logic_vector(7 downto 0)
         );
    end component uart_rx;
    
    component Wrapper is
      port (
            -- input side
            clk, rst      : in  std_logic;
            next_in       : out std_logic;      
            in_valid      : in  std_logic;  
            data_in_1     : in  std_logic_vector(31 downto 0);
            data_in_2     : in  std_logic_vector(31 downto 0);
            ctr           : in  unsigned(1 downto 0);
            -- output side
            next_out      : in  std_logic;
            out_valid     : out std_logic;
            data_out      : out std_logic_vector(31 downto 0)
           );
    end component Wrapper;
    
    signal TX_DV                                : std_logic := '0';
    signal RX_DV                                : std_logic;
    signal DATA_in, DATA_out                    : std_logic_vector(7 downto 0) := (others => '1');
    signal IV_count                             : std_logic_vector(3 downto 0) := (others => '0');
    signal OV_count,OV_count_reg                : std_logic_vector(3 downto 0) := "0100";
    signal data_in_1, data_in_2                 : std_logic_vector(31 downto 0);
    signal data_in_1_reg                        : std_logic_vector(31 downto 0);
    signal data_in_2_reg                        : std_logic_vector(31 downto 0);
    signal in_valid, out_valid                  : std_logic := '0';
    signal ctrl_bits, ctrl_reg                  : unsigned(1 downto 0);
    signal in_valid_reg, in_valid_reg_2         : std_logic := '0';
    signal data_out_reg                         : std_logic_vector(31 downto 0) := (others => '0');
    signal RST                                  : std_logic;
    signal next_in, next_out                    : std_logic;    
    signal tx_done, tx_done_reg, tx_done_reg_2  : std_logic;
    
begin

  -- Instantiate UART Receiver
   UART_RX_INST : uart_rx
    generic map (
      g_CLKS_PER_BIT => c_CLKS_PER_BIT
      )
    port map (
      i_clk       => CLK,
      i_rx_serial => UART_RXD,
      o_rx_dv     => RX_DV,
      o_rx_byte   => DATA_in
      );
    
    process(CLK)
    begin
        if rising_edge(CLK) then
            if RX_DV = '1' then
                IV_count <= IV_count + 1;
            else
                IV_count <= IV_count;
            end if;
            if IV_count = 9 then
                IV_count <= "0000";
            end if;
        end if;
    end process;
    
    process(RX_DV)
    begin
        if rising_edge(RX_DV) then
            if IV_count = 0 then
                data_in_1_reg(7 downto 0) <= DATA_in;
                in_valid <= '0';
            elsif IV_count = 1 then
                data_in_1_reg(15 downto 8) <= DATA_in;
                in_valid <= '0';
            elsif IV_count = 2 then
                data_in_1_reg(23 downto 16) <= DATA_in;
                in_valid <= '0';
            elsif IV_count = 3 then
                data_in_1_reg(31 downto 24) <= DATA_in;
                in_valid <= '0';
            elsif IV_count = 4 then
                data_in_2_reg(7 downto 0) <= DATA_in;
                in_valid <= '0';
            elsif IV_count = 5 then
                data_in_2_reg(15 downto 8) <= DATA_in;
                in_valid <= '0';
            elsif IV_count = 6 then
                data_in_2_reg(23 downto 16) <= DATA_in;
                in_valid <= '0';
            elsif IV_count = 7 then
                data_in_2_reg(31 downto 24) <= DATA_in;
                in_valid <= '0';
            elsif IV_count = 8 then
                ctrl_reg <= unsigned(DATA_in(2 downto 1));
                in_valid <= DATA_in(0);
            else
                in_valid <= '0';
            end if;
        end if;
    end process;
    
    process(CLK)
    begin
        if rising_edge(CLK) then
             in_valid_reg <= in_valid;
             if(in_valid_reg = '0' and in_valid = '1') then
                   in_valid_reg_2 <= '1';
                   data_in_1 <= data_in_1_reg;
                   data_in_2 <= data_in_2_reg;
                   ctrl_bits <= ctrl_reg;
                else
                   in_valid_reg_2 <= '0';
                end if;
        end if;
    end process;

    RST <= '0';
    next_out <= '1';
    
    Wrapper_INST : Wrapper
    port map (
        clk         => CLK,
        rst         => RST,
        next_in     => next_in,
        in_valid    => in_valid_reg_2,
        data_in_1   => data_in_1,
        data_in_2   => data_in_2,
        next_out    => next_out,
        out_valid   => out_valid,
        data_out    => data_out_reg,
        ctr         => ctrl_bits    
    );
    
    process(CLK)
    begin
        if(rising_edge(CLK)) then 
           if out_valid = '1' then
               OV_count <= "0000";
           else
               if(OV_count = "0100") then
                   OV_count <= OV_count;
               elsif(tx_done_reg_2 = '1') then
                   OV_count <= OV_count + 1;
               else
                   OV_count <= OV_count;
               end if;
           end if;
        end if;
    end process;
   
    process(CLK)
        begin
           if rising_edge(CLK) then
                tx_done_reg <= tx_done;
                if(tx_done_reg = '0' and tx_done = '1') then
                  tx_done_reg_2 <= '1';
               else
                  tx_done_reg_2 <= '0';
           end if;
       end if;
    end process; 
   
    process(CLK)
    begin
        if rising_edge(CLK) then
            OV_count_reg <= OV_count;
             if(OV_count_reg /= OV_count) then
                if(OV_count = "0100") then
                   TX_DV <= '0';
                else 
                   TX_DV <= '1';
                end if;
             else
                   TX_DV <= '0';
                end if;
        end if;
    end process;
    
    process(CLK)
    begin
        if rising_edge(CLK) then
            if OV_count = 0 then
                DATA_out <= data_out_reg(7 downto 0);
            elsif OV_count = 1 then
                DATA_out <= data_out_reg(15 downto 8);
            elsif OV_count = 2 then
                DATA_out <= data_out_reg(23 downto 16);
            elsif OV_count = 3 then
                DATA_out <= data_out_reg(31 downto 24); 
            end if;
        end if;
    end process;

    -- Instantiate UART transmitter
    UART_TX_INST : uart_tx
    generic map (
      g_CLKS_PER_BIT => c_CLKS_PER_BIT
      )
    port map (
      i_clk       => CLK,
      i_tx_dv     => TX_DV,
      i_tx_byte   => DATA_out,
      o_tx_active => open,
      o_tx_serial => UART_TXD,
      o_tx_done   => tx_done
      );
      
end arch;
