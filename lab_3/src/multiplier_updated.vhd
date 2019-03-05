--Engineer     : 
--Date         : 
--Name of file : multiplier_updated.vhd
--Description  : implements 2 simple 8b*8b signed multipliers
--               DSP slice

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity multiplier_updated is
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
end multiplier_updated;
-- DO NOT MODIFY PORT NAMES ABOVE


architecture arch of multiplier_updated is
begin
end arch;
