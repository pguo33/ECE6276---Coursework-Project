
--Engineer     : Yanshen Su
--Date         : 9/18/2018
--Name of file : filter_8.vhd
--Description  : implements 8-tap FIR filter 
--               with 8-bit signed input data and 
--               8-bit real and imag coefs
--               with handshake at input/output side

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity filter_8 is
  port (
        -- input side
        clk, rst      : in  std_logic;
        next_in       : out std_logic;
        in_valid      : in  std_logic;
        data_in       : in  signed (7 downto 0);
        -- output side
        next_out      : in  std_logic;
        out_valid     : out std_logic;
        data_real_out : out signed (9 downto 0);
        data_imag_out : out signed (9 downto 0)
       );
end filter_8;
-- DO NOT MODIFY PORT NAMES ABOVE


architecture arch of filter_8 is
  -- ********************** DEFINE TYPES **********************
  type array8x8b_t      is array (0 to 7) of signed (7 downto 0);
  type array4x17b_t     is array (0 to 3) of signed (16 downto 0);
  type array2x18b_t     is array (0 to 1) of signed (17 downto 0);
  type array8x1b_t      is array (0 to 7) of std_logic;
  -- ********************** DEFINE SIGNALS **********************
  signal coef_real     : array8x8b_t;
  signal coef_imag     : array8x8b_t;
  -- ****************** P0-P7 Stages *******************
  -- 8 data flopped 
  signal stall_p       : array8x1b_t;
  signal valid_p       : array8x1b_t;
  signal data_p        : array8x8b_t;
  signal valid_p06     : std_logic; -- valid p0~6, when all 7 flops are valid, valid_p06 = 1
  signal valid_p07     : std_logic; -- valid p0~7, when all 8 flops are valid, valid_p07 = 1
  -- ****************** P8 Stage *******************
  -- 8 multiplications (8bit*8bit=16bits) and 4 additions (16bit+16bit->17bits)
  signal stall_p8          : std_logic;
  signal valid_p8          : std_logic;
  signal data_real_p8      : array4x17b_t;
  signal data_imag_p8      : array4x17b_t;
  -- ****************** P9 Stage *******************
  -- 4 numbers ---- 2 additions (17bit+17bit = 18bit)----> 2 numbers out
  signal stall_p9      : std_logic;
  signal valid_p9      : std_logic;
  signal data_real_p9  : array2x18b_t;
  signal data_imag_p9  : array2x18b_t;
  -- ****************** P10 Stage *******************
  -- 2 numbers ---- 1 addition (18bit+18bit = 19bit) and right shift by 9 bits----> 1 number out
  signal stall_p10     : std_logic;
  signal valid_p10     : std_logic;
  signal data_real     : signed (18 downto 0);
  signal data_imag     : signed (18 downto 0);
  signal data_real_p10 : signed (9 downto 0);
  signal data_imag_p10 : signed (9 downto 0);
begin
  coef_real(0) <= "10110010";
  coef_imag(0) <= "11100011";
  coef_real(1) <= "10100101";
  coef_imag(1) <= "11101110";
  coef_real(2) <= "00111000";
  coef_imag(2) <= "10010100";
  coef_real(3) <= "10001000";
  coef_imag(3) <= "01011011";
  coef_real(4) <= "01010010";
  coef_imag(4) <= "10001001";
  coef_real(5) <= "00110000";
  coef_imag(5) <= "01110100";
  coef_real(6) <= "00000000";
  coef_imag(6) <= "11100011";
  coef_real(7) <= "10011000";
  coef_imag(7) <= "01010100";
  -- ********************** DO OPERATIONS **********************
  -- ****************** P0-P7 Stages *******************
  process (clk) 
  begin
    if (rising_edge(clk)) then
      if (rst = '1') then 
        for i in 0 to 7 loop
          valid_p(i) <= '0';
        end loop;
      else 
        -- P0 stage
        if (not stall_p(0)) then 
          valid_p(0) <= in_valid;
          if (in_valid = '1') then 
            data_p(0) <= data_in;
          end if;
        end if;
        -- P1-7 stage
        for i in 1 to 7 loop
          if (not stall_p(i)) then 
            valid_p(i) <= valid_p(i-1);
            if (valid_p(i-1) = '1') then 
              data_p(i) <= data_p(i-1);
            end if;
          end if;
        end loop;
      end if;
    end if;
  end process;

  -- Stall signals for P0-7
  -- P0-6 stages
  gen_stall0_6: for i in 0 to 6 generate
    stall_p(i) <= stall_p(i+1) and valid_p(i);
  end generate gen_stall0_6;
  -- P7 stage
  valid_p06 <= valid_p(6) and valid_p(5) and valid_p(4) and valid_p(3) and valid_p(2) and valid_p(1) and valid_p(0);
  stall_p(7) <= valid_p(7) and (stall_p8 or (not valid_p06));

  valid_p07 <= valid_p06 and valid_p(7);

  -- ****************** P8 Stage *******************
  -- 8 multiplications (8bit*8bit=16bits) and 4 additions (16bit+16bit->17bits)
  stall_p8 <= stall_p9 and valid_p8;

  process (clk) 
  begin 
    if (rising_edge(clk)) then
      if (rst = '1') then 
        valid_p8 <= '0';
      elsif (not stall_p8) then
        valid_p8 <= valid_p07;
        if (valid_p07 = '1') then
          for i in 0 to 3 loop
            data_real_p8(i) <= resize(signed(data_p(2*i) * coef_real(2*i)), 17)
                             + resize(signed(data_p(2*i+1) * coef_real(2*i+1)), 17);
            data_imag_p8(i) <= resize(signed(data_p(2*i) * coef_imag(2*i)), 17)
                             + resize(signed(data_p(2*i+1) * coef_imag(2*i+1)), 17);
          end loop;
        end if;
      end if;
    end if;
  end process;


  -- ****************** P9 Stage *******************
  -- 4 numbers ---- 2 additions (17bit+17bit = 18bit)----> 2 numbers out
  stall_p9 <= stall_p10 and valid_p9;

  process (clk) 
  begin 
    if (rising_edge(clk)) then
      if (rst = '1') then 
        valid_p9 <= '0';
      elsif (not stall_p9) then
        valid_p9 <= valid_p8;
        if (valid_p8 = '1') then
          for i in 0 to 1 loop
            data_real_p9(i) <= resize(signed(data_real_p8(2*i)), 18) + resize(signed(data_real_p8(2*i+1)), 18);
            data_imag_p9(i) <= resize(signed(data_imag_p8(2*i)), 18) + resize(signed(data_imag_p8(2*i+1)), 18);
          end loop;
        end if;
      end if;
    end if;
  end process;

  -- ****************** P10 Stage *******************
  -- 2 numbers ---- 1 addition (18bit+18bit = 19bit) and right shift by 9 bits----> 1 number out
  stall_p10 <= (not next_out) and valid_p10;

  data_real <= resize(signed(data_real_p9(0)), 19) + resize(signed(data_real_p9(1)), 19);
  data_imag <= resize(signed(data_imag_p9(0)), 19) + resize(signed(data_imag_p9(1)), 19);

  process (clk) 
  begin 
    if (rising_edge(clk)) then
      if (rst = '1') then 
        valid_p10 <= '0';
      elsif (not stall_p10) then
        valid_p10 <= valid_p9;
        if (valid_p9 = '1') then
          for i in 0 to 1 loop
            data_real_p10 <= data_real(18 downto 9);
            data_imag_p10 <= data_imag(18 downto 9);
          end loop;
        end if;
      end if;
    end if;
  end process;

  -- ****************** Output Stage *******************
  data_real_out <= data_real_p10;
  data_imag_out <= data_imag_p10;
  out_valid     <= valid_p10;
  next_in       <= not stall_p(0);
end arch;
