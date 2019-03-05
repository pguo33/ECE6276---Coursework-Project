--Engineer     : 
--Date         :
--Name of file : multiplier_lab4.vhd
--Description  : implements concatenated signed multipliers
--               in DSP slice with handshake protocol

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity multiplier_lab4 is
  port (
        -- input side
        clk, rst   : in  std_logic;
        next_in    : out std_logic;
        in_valid   : in  std_logic;
        data_in_1  : in  signed (7 downto 0);
        data_in_2  : in  signed (7 downto 0);
        coef_in    : in  signed (7 downto 0);
        -- output side
        next_out   : in  std_logic;
        out_valid  : out std_logic;
        data_out_1 : out signed (15 downto 0);
        data_out_2 : out signed (15 downto 0)
       );
end multiplier_lab4;
-- DO NOT MODIFY PORT NAMES ABOVE


architecture arch of multiplier_lab4 is
begin
end arch;
