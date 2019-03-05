--Engineer     : 
--Date         : 
--Name of file : sequence_detector.vhd
--Description  : implements a sequence detector 
--               detecting "101110" using state machine

library ieee;
use ieee.std_logic_1164.all;

entity sequence_detector is
  port (
        clk, rst  : in  std_logic;
        data_in   : in  std_logic;
        data_out  : out std_logic 
       );
end sequence_detector;
-- DO NOT MODIFY THE PORT NAME ABOVE

architecture arch of sequence_detector is
begin
end arch;
