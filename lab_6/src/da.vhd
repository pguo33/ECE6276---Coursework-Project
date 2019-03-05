-- Engineer     : 
-- Date         : 
-- Name of file : da.vhd
-- Description  : implements a signed Distributed Arithmetic,
--                with 4 signed input vectors. Each is 4-bit wide.
--                The coefs are also 4-bit wide signed numbers

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity da is
  port (
       -- input side
       clk, rst       : in  std_logic;
       data_in_0      : in  signed (3 downto 0);
       data_in_1      : in  signed (3 downto 0);
       data_in_2      : in  signed (3 downto 0);
       data_in_3      : in  signed (3 downto 0);
       in_valid       : in  std_logic;
       next_in        : out std_logic;
       -- output side
       data_out       : out signed (9 downto 0);
       out_valid      : out std_logic;
       );
end da;
-- DO NOT MODIFY PORT NAMES ABOVE

architecture arch of da is
begin
end arch;
