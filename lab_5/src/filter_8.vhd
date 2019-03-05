
--Engineer     : 
--Date         : 
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
  -- ********************** DEFINE SIGNALS **********************
  signal coef_real     : array8x8b_t;
  signal coef_imag     : array8x8b_t;

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

end arch;
