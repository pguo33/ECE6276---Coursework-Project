--Engineer     : Dingxin Jin
--Date         : 11/10/2018
--Name of file : Normalization.vhd
--Description  : Find leading 1, check overflow/underflow, normalize and denormalize

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity Normalization is
  port (
        -- input side
        clk, rst      : in  std_logic;
        next_in       : out std_logic;      
        in_valid      : in  std_logic;  
	mant_in       : in  unsigned(47 downto 0); -- 23+ (+)127 + (-)126
        exp_in        : in  unsigned(9 downto 0); -- 8+1+guard bits
        sign_in       : in  std_logic;

        -- output side
	next_out      : in  std_logic;
        out_valid     : out std_logic;
        data_out      : out std_logic_vector(31 downto 0)
       );
end Normalization;
-- DO NOT MODIFY PORT NAMES ABOVE

architecture arch of Normalization is
  -- ********************** DEFINE SIGNALS ********************
  ----------------------------Stage 1--------------------------
  signal mant_reg_1   : unsigned(47 downto 0);
  signal exp_reg_1    : unsigned(9 downto 0);--Extra 1 bit for overflow & underflow
  signal sign_reg_1   : std_logic;
  signal data_reg_1   : unsigned(47 downto 0);
  signal data_valid_1 : std_logic;
  signal data_stall_1 : std_logic;
  ----------------------------Stage 2--------------------------
  signal mant_reg_2   : unsigned(23 downto 0); --Extra 1 bit for rounding
  signal exp_reg_2    : unsigned(9 downto 0); 
  signal sign_reg_2   : std_logic;
  signal data_valid_2 : std_logic;
  signal data_stall_2 : std_logic;
  ----------------------------Stage 2--------------------------
  signal mant_reg_3   : unsigned(22 downto 0);
  signal exp_reg_3    : unsigned(7 downto 0); 
  signal sign_reg_3   : std_logic;
  signal data_valid_3 : std_logic;
  signal data_stall_3 : std_logic;

begin
  -- -------------- Stall Signals  -----------------
  Stall: process(data_stall_1, data_stall_2, data_stall_3, next_out, data_valid_1, data_valid_2, data_valid_3)
  begin
    next_in <= not data_stall_1;
    data_stall_1 <= data_valid_1 and data_stall_2;
    data_stall_2 <= data_valid_2 and data_stall_3;
    data_stall_3 <= data_valid_3 and (not next_out);
  end process;

  ----------------------------Stage 1--------------------------
  FindTail1: process(clk)
    variable data_tmp_0 : unsigned(47 downto 0);
    variable data_tmp_1 : unsigned(47 downto 0);
    variable data_tmp_2 : unsigned(47 downto 0);
  begin
    if (rising_edge(clk)) then
      if (rst = '1') then   
        data_valid_1 <= '0';
      else
        if (data_stall_1 = '0') then
          data_valid_1 <= in_valid;
          if (in_valid = '1') then
	    for i in 0 to 47 loop
              data_tmp_0(47 - i) := mant_in(i);  -- LSB to MSB
            end loop;
	    data_tmp_2 := data_tmp_0 - 1;
            data_tmp_1 := data_tmp_2 xor data_tmp_0;
            data_reg_1 <= data_tmp_1 and data_tmp_0;

            mant_reg_1 <= mant_in;
            exp_reg_1  <= exp_in;
            sign_reg_1 <= sign_in;

          end if;
        end if;
      end if;
    end if;
  end process;

  ----------------------------Stage 2--------------------------
  LUT: process(clk)
    variable FLAG           : std_logic;
  begin
    if (rising_edge(clk)) then
      if (rst = '1') then   
        data_valid_2 <= '0';
      else
        if (data_stall_2 = '0') then
          data_valid_2 <= data_valid_1;
          if (data_valid_1 = '1') then
            sign_reg_2 <= sign_reg_1;   
            --all 0
            if(data_reg_1 = shift_right(data_reg_1,1)) then
              mant_reg_2 <= (others => '0'); 
              exp_reg_2  <= exp_reg_1; 
            --NaN
            elsif(exp_reg_1 = "0011111111" and data_reg_1(47) = '1') then
              mant_reg_2(23 downto 1) <= (others => '0'); 
              mant_reg_2(0) <= '1'; 
              exp_reg_2  <= exp_reg_1; 
            --has 1
            else
              for i in 0 to 23 loop
                if(data_reg_1(i) = '1') then
                  mant_reg_2 <= mant_reg_1(46 - i downto 23 - i);
                  exp_reg_2  <= exp_reg_1; 
                end if;
              end loop;

              if(data_reg_1(24) = '1') then
                mant_reg_2(23 downto 1) <= mant_reg_1(22 downto 0);
                mant_reg_2(0) <= '0';
                exp_reg_2  <= exp_reg_1; 
              end if;

              for i in 25 to 47 loop
                if(data_reg_1(i) = '1') then          
                  exp_reg_2  <= exp_reg_1; 
                  mant_reg_2(23 downto i+1 - 25) <= mant_reg_1(47 - i downto 0);
                  mant_reg_2(i+1 - 25 downto 0)  <= (others => '0');
                end if;
              end loop;   
                
            end if;    
          end if;
        end if;
      end if;
    end if;
  end process;

  ----------------------------Stage 3--------------------------
  Exception: process(clk)
    variable mant_reg_2_tmp    : unsigned(23 downto 0);
    variable mant_reg_2_tmp_d  : unsigned(24 downto 0);
    variable mant_reg_2_tmp_z  : unsigned(24 downto 0);
    variable exp_reg_2_tmp     : unsigned(9 downto 0);
  begin
    if (rising_edge(clk)) then
      if (rst = '1') then   
        data_valid_3 <= '0';
      else
        if (data_stall_3 = '0') then
          data_valid_3 <= data_valid_2;
          if (data_valid_2 = '1') then     
            sign_reg_3 <= sign_reg_2;    
            --Round
            mant_reg_2_tmp := mant_reg_2 + to_unsigned(1,24); 
            --Denormalize
            exp_reg_2_tmp := to_unsigned(0,10) - exp_reg_2(9 downto 0);     
            --Overflow
            if(exp_reg_2(9) = '0' and exp_reg_2(8) = '1') then
              exp_reg_3  <= (others => '1');
              mant_reg_3 <= (others => '0');  
            --Excepetion inf   
            elsif(exp_reg_2(9 downto 0) = "0011111111" and mant_reg_2 /= "00000000000000000000001") then
              exp_reg_3  <= (others => '1');
              mant_reg_3 <= (others => '0');   
            --Underflow                         
            elsif(exp_reg_2(9) = '1' and exp_reg_2(8) = '1') then
              --Denormalized
              if(exp_reg_2_tmp < to_unsigned(24,10) ) then
                exp_reg_3  <= (others => '0');

                for i in 1 to 22 loop  --need to shift i bit
                  if( exp_reg_2_tmp  = to_unsigned(i,10)) then
                    mant_reg_2_tmp_d := (others => '0');
                    mant_reg_2_tmp_d := mant_reg_2_tmp_d + ('1' & mant_reg_2(23 downto i + 1)) + to_unsigned(1,24);
                    mant_reg_3 <= mant_reg_2_tmp_d(23 downto 1);
                  end if;
                end loop;

                if( exp_reg_2_tmp  = to_unsigned(23,10)) then
                  mant_reg_2_tmp_d := (others => '0');
                  mant_reg_2_tmp_d := mant_reg_2_tmp_d + to_unsigned(1,24) + to_unsigned(1,24);
                  mant_reg_3 <= mant_reg_2_tmp_d(23 downto 1);
                end if;

	      else               
                exp_reg_3  <= (others => '0');
                mant_reg_3 <= (others => '0');
              end if;
            else
              exp_reg_3  <= exp_reg_2(7 downto 0);

              if( exp_reg_2  = to_unsigned(0,10) and mant_reg_2(23 downto 0) /= "000000000000000000000000") then
                  mant_reg_2_tmp_z := (others => '0');
                  mant_reg_2_tmp_z := mant_reg_2_tmp_z + ('1' & mant_reg_2(23 downto 1)) + to_unsigned(1,24);
                  mant_reg_3 <= mant_reg_2_tmp_z(23 downto 1);
              else
                  mant_reg_3 <= mant_reg_2_tmp(23 downto 1);
              end if;

            end if;   
          end if;
        end if;
      end if;
    end if;
  end process;  

  ----------------------------Output--------------------------
  out_valid <= next_out and data_valid_3;
  data_out  <= std_logic_vector(sign_reg_3 & exp_reg_3 & mant_reg_3);

end arch;