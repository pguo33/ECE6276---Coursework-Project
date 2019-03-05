--Engineer     : 
--Date         : 8/27/2018
--Name of file : barrel_shifter.vhd
--Description  : implements a left-shifted barrel shifter
--               of data width 16 bits

library ieee;
use ieee.std_logic_1164.all;
entity barrel_shifter is
    --port list
    port(
         input  : in  std_logic_vector(15 downto 0); -- input data
         ctrl   : in  std_logic_vector(3 downto 0);  -- control word
         output : out std_logic_vector(15 downto 0)  -- output data
        );
end barrel_shifter ;

architecture barrel_arch of barrel_shifter is

begin
  with ctrl select
    output <= input                                    when "0000",
              input(14 downto 0) & input(15)           when "0001",
              -- Complete your design below this line
              (others => '0')                          when others;

end barrel_arch; 