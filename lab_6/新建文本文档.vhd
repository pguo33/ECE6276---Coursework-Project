-- Engineer     : Peng Guo
-- Date         : 2018/10/11
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
       out_valid      : out std_logic
       );
end da;
-- DO NOT MODIFY PORT NAMES ABOVE

architecture arch of da is
-- ********************** DEFINE TYPES **********************
  type array4x4b_t      is array (0 to 3) of signed (3 downto 0);
-- ***************** Define Signals **************************
  signal coef         : array4x4b_t;

  signal valid_p1     : std_logic;
  signal valid_p0     : std_logic;
  signal address      : signed (3 downto 0);
  signal ctrl_p1      : signed (1 downto 0);
  signal result       : signed (5 downto 0);
  signal result_reg   : signed (9 downto 0);
  signal sum          : signed (9 downto 0);
  signal valid_p2     : std_logic;
  signal ready        : std_logic;
--  signal ctrl_p2      : signed (1 downto 0);

begin
  coef(0) <= "0111";
  coef(1) <= "0011";
-- Negative coef
  coef(2) <= "1000";
  coef(3) <= "1011";

valid_p1 <= in_valid;

-------p0 in_valid delay------
process(clk)
begin
  if (rising_edge (clk)) then
     if (rst= '1') then
        valid_p0 <= '0';
     else
        valid_p0 <= valid_p1;
     end if;
  end if;
end process;

--------address/count------
process(clk)
begin
  if (rising_edge (clk)) then
     if (rst = '1') then
        ctrl_p1 <= "00";
     else
       if (valid_p1 = '1') then
          ctrl_p1 <= ctrl_p1 + "01";
          if (ctrl_p1 = "00") then
             address <= data_in_3(0) & data_in_2(0) & data_in_1(0) & data_in_0(0);     
          elsif (ctrl_p1 = "01") then
             address <= data_in_3(1) & data_in_2(1) & data_in_1(1) & data_in_0(1);
          elsif (ctrl_p1 = "10") then
             address <= data_in_3(2) & data_in_2(2) & data_in_1(2) & data_in_0(2);
          elsif (ctrl_p1 = "11") then
             address <= data_in_3(3) & data_in_2(3) & data_in_1(3) & data_in_0(3);
          end if;
      end if;
    end if;
  end if;
end process;

---------accumulation/output---------
process(clk)
begin
  if (rising_edge (clk)) then
     if (rst = '1') then
        valid_p2 <= '0';
     else
        if (ctrl_p1 = "00") then
           valid_p2 <= valid_p0;
           sum <= shift_right(sum,1) - result_reg;
        elsif (ctrl_p1 = "01") then
           valid_p2 <= '0';
           sum <= result_reg;
        elsif (ctrl_p1 = "10") then
           valid_p2 <= '0';
           sum <= shift_right(sum,1) + result_reg;
        elsif (ctrl_p1 = "11") then
           valid_p2 <= '0';
           sum <= shift_right(sum,1) + result_reg;
        end if;
     end if;
  end if;
end process;

----------next_in------------
process(valid_p1, ctrl_p1)
begin
  if(valid_p1 = '0') then
    ready <= '1';
  else
    if(ctrl_p1 = "11") then
      ready <= '1';
    else
      ready <= '0';
    end if;
  end if;
end process;

----------LUT----------
process(address)
begin
case address is
when "0000" => 
   result <= "000000";
when "0001" =>
   result <= "00" & coef(0);
when "0010" =>
   result <= "00" & coef(1);
when "0011" =>
   result <= ("00" & coef(1)) + ("00" & coef(0));
when "0100" =>
   result <= "11" & coef(2);
when "0101" =>
   result <= ("11" & coef(2)) + ("00" & coef(0));
when "0110" =>
   result <= ("11" & coef(2)) + ("00" & coef(1));
when "0111" =>
   result <= ("11" & coef(2)) + ("00" & coef(1)) + ("00" & coef(0));
when "1000" =>
   result <= "11" & coef(3);
when "1001" =>
   result <= ("11" & coef(3)) + ("00" & coef(0));
when "1010" =>
   result <= ("11" & coef(3)) + ("00" & coef(1));
when "1011" =>
   result <= ("11" & coef(3)) + ("00" & coef(1)) + ("00" & coef(0));
when "1100" =>
   result <= ("11" & coef(3)) + ("11" & coef(2));
when "1101" =>
   result <= ("11" & coef(3)) + ("11" & coef(2)) + ("00" & coef(0));
when "1110" =>
   result <= ("11" & coef(3)) + ("11" & coef(2)) + ("00" & coef(1));
when "1111" =>
   result <= ("11" & coef(3)) + ("11" & coef(2)) + ("00" & coef(1))+ ("00" & coef(0));
when others =>
   result <= "000000";
end case;
end process;

result_reg <= result(5) & result & "000";

data_out <= sum;
next_in <= ready;
out_valid <= valid_p2;

end arch;
