--Engineer     : Peng Guo
--Date         : 2018/9/14
--Name of file : multiplier.vhd
--Description  : implements 2 simple 8b*8b signed multipliers

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity multiplier is
  port (
        -- input ports
        clk, rst   : in std_logic;
        in_valid   : in std_logic;
        data_in_1  : in signed (7 downto 0);
        data_in_2  : in signed (7 downto 0);
        coef_in    : in signed (7 downto 0);
        -- output ports
        out_valid  : out std_logic;
        data_out_1 : out signed (15 downto 0);
        data_out_2 : out signed (15 downto 0)
       );
end multiplier;
-- DO NOT MODIFY PORT NAMES ABOVE

architecture arch of multiplier is
begin
end arch;

