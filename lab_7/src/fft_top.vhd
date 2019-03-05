
--Engineer     : 
--Date         : 
--Name of file : fft_top.vhd
--Description  : implements 8-point FFT

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.fft_pkg.all;

entity fft_top is
  port (
        -- input side
        clk, rst      : in std_logic;
        data_in       : in data_in_t;
        in_valid      : in std_logic;
        next_in       : out std_logic;
        -- output side
        out_valid     : out std_logic;
        data_real_out : out data_out_t;
        data_imag_out : out data_out_t
       );
end fft_top;
-- DO NOT MODIFY PORT NAMES ABOVE


architecture arch of fft_top is
begin
end arch;
