--Engineer     : Peng Guo
--Date         : 2018/9/24
--Name of file : multiplier_lab4.vhd
--Description  : implements concatenated signed multipliers
--               in DSP slice with handshake protocol

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity multiplier_updated is
  port (
        -- input side
        clk, rst   : in  std_logic;
        in_valid   : in  std_logic;
        data_in_1  : in  signed (7 downto 0);
        data_in_2  : in  signed (7 downto 0);
        coef_in    : in  signed (7 downto 0);
        -- output side
        out_valid  : out std_logic;
        data_out_1 : out signed (15 downto 0);
        data_out_2 : out signed (15 downto 0)
       );
end multiplier_updated;
-- DO NOT MODIFY PORT NAMES ABOVE


architecture arch of multiplier_updated is
  signal valid_in : std_logic;
  signal valid_out : std_logic;
  signal data_out_reg_1 : signed (15 downto 0);
  signal data_out_reg_2 : signed (15 downto 0);
  signal data_out_together : signed (31 downto 0);
  signal data_out_together_reg : signed (31 downto 0);
  signal data_in_reg_1 : signed (23 downto 0);
  signal data_in_reg_2 : signed (23 downto 0);
  signal data_in_together : signed (23 downto 0);
  signal data_in_together_reg : signed (23 downto 0);
  signal coef_in_long : signed (17 downto 0);
  signal coef_in_reg : signed (17 downto 0);
  signal allzero : signed (15 downto 0);
  signal all_signbit_in : signed (15 downto 0);
  signal all_signbit_coef : signed (9 downto 0);
begin

      allzero <= (others => '0');
      all_signbit_in <= (others => data_in_2(7));
      all_signbit_coef <= (others => coef_in(7));
      data_in_reg_1 <= (data_in_1(7 downto 0) & allzero);
      data_in_reg_2 <= (all_signbit_in & data_in_2);
      coef_in_long <= (all_signbit_coef & coef_in);
      data_in_together <= data_in_reg_1 + data_in_reg_2;


  process(clk)
    begin
      if rising_edge (clk) then
        if(rst = '1') then
          valid_in <= '0';
          data_in_together_reg <= (others => '0');
          coef_in_reg <= (others => '0');
        elsif(rst = '0') then
          valid_in <= in_valid;
          data_in_together_reg <= data_in_together;
          coef_in_reg <= coef_in_long;
        end if;
      end if;
  end process;


      data_out_together <= data_in_together_reg * coef_in_reg(7 downto 0);


  process(clk)
    begin
      if rising_edge (clk) then
        if(rst = '1') then
          data_out_together_reg <= (others => '0');
          valid_out <= '0';
        elsif(rst = '0') then
          data_out_together_reg <= data_out_together;
          valid_out <= valid_in;
        end if;
      end if;
  end process;


      data_out_reg_1 <= data_out_together_reg (31 downto 16) + data_out_together_reg (15 downto 15);
      data_out_reg_2 <= data_out_together_reg (15 downto 0);


  process(clk)
    begin
      if rising_edge (clk) then
        if(rst = '1') then
          out_valid <= '0';
          data_out_1 <= (others => '0');
          data_out_2 <= (others => '0');
        elsif(rst ='0') then
          out_valid <= valid_out;
          data_out_1 <= data_out_reg_1;
          data_out_2 <= data_out_reg_2;
        end if;
      end if;
  end process;

end arch;
