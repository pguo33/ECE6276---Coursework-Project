
--Engineer     : Shengwei Lyu, Dingxin Jin
--Date         : 11/16/2018
--Name of file : FP_mult.vhd
--Description  : implements floating point multiplication 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity FP_mult is
	port(
			clk,rst		: in std_logic;
			in_valid	: in std_logic;
			next_in		: out std_logic;
			data_in_1	: in std_logic_vector(31 downto 0);
			data_in_2	: in std_logic_vector(31 downto 0);

			next_out	: in std_logic;
			out_valid	: out std_logic;  
			mant_out  	: out unsigned(47 downto 0); 
    			exp_out        	: out unsigned(9 downto 0); 
    			sign_out       	: out std_logic
		);
end FP_mult;

architecture arch of FP_mult is
	signal data1_sig, data_1_den: std_logic;
	signal data1_exp: std_logic_vector(7 downto 0);
	signal data1_man: std_logic_vector(22 downto 0);

	signal data2_sig, data_2_den: std_logic;
	signal data2_exp: std_logic_vector(7 downto 0);
	signal data2_man: std_logic_vector(22 downto 0);

	signal ans_sig, ans_exc: std_logic;
	signal ans_exp: unsigned(9 downto 0);
	signal ans_man: unsigned(47 downto 0);

	signal ans_sig_2: std_logic;
	signal ans_exp_2: unsigned(9 downto 0);
	signal ans_man_2: unsigned(47 downto 0);

	signal bias: unsigned(7 downto 0);

	signal valid_p1, valid_p2, valid_p3, stall_p1, stall_p2, stall_p3: std_logic;
	signal data_out_reg: std_logic_vector(31 downto 0);
begin
  -- -------------- Stall Signals  -----------------
  Stall: process(stall_p1,stall_p2,stall_p3,next_out,valid_p1,valid_p2,valid_p3)
  begin
    next_in <= not stall_p1;
    stall_p1 <= valid_p1 and stall_p2;
    stall_p2 <= valid_p2 and stall_p3;
    stall_p3 <= valid_p3 and (not next_out);
  end process;

	bias <= to_unsigned(127,8);


	p1: process(clk) -- input data and recover denormalized num
    		variable data_tmp_0 : unsigned(22 downto 0);
    		variable data_tmp_1 : unsigned(22 downto 0);
    		variable data_tmp_2 : unsigned(22 downto 0);
    		variable data_tmp_3 : unsigned(22 downto 0);

    		variable data_tmp_4 : unsigned(22 downto 0);
    		variable data_tmp_5 : unsigned(22 downto 0);
    		variable data_tmp_6 : unsigned(22 downto 0);
    		variable data_tmp_7 : unsigned(22 downto 0);
	begin
		if rising_edge(clk) then
			if rst = '1' then
				valid_p1 <= '0';
			else
				if stall_p1 = '0' then
					--normalize the denormalized num
					if(data_in_1(30 downto 23) = "00000000" and data_in_1(22 downto 0) /= "00000000000000000000000") then
						data_1_den <= '1';
	    					for i in 0 to 22 loop
              						data_tmp_0(22 - i) := data_in_1(i);  -- LSB to MSB
            					end loop;

	    					  data_tmp_2 := data_tmp_0 - 1;
            					  data_tmp_1 := data_tmp_2 xor data_tmp_0;
            					  data_tmp_3 := data_tmp_1 and data_tmp_0;

              					for i in 0 to 21 loop
                					if(data_tmp_3(i) = '1') then
                  						data1_exp <= std_logic_vector(unsigned(data_in_1(30 downto 23)) - to_unsigned(i+1, 8));
						                data1_man(22 downto i + 1) <= data_in_1(21 - i downto 0);
						                data1_man( i downto 0) <= (others => '0');
                					end if;
              					end loop;

                				if(data_tmp_3(22) = '1') then
                  					data1_exp <= std_logic_vector(unsigned(data_in_1(30 downto 23)) - to_unsigned(23, 8));
						        data1_man <= (others => '0');
                				end if;

						  data1_sig <= data_in_1(31);
					else
						data_1_den <= '0';
						data1_sig <= data_in_1(31);
						data1_exp <= data_in_1(30 downto 23);
						data1_man <= data_in_1(22 downto 0);
					end if;

					
					if(data_in_2(30 downto 23) = "00000000" and data_in_2(22 downto 0) /= "00000000000000000000000") then
						data_2_den <= '1';
	    					for i in 0 to 22 loop
              						data_tmp_4(22 - i) := data_in_2(i);  -- LSB to MSB
            					end loop;

	    					  data_tmp_6 := data_tmp_4 - 1;
            					  data_tmp_5 := data_tmp_6 xor data_tmp_4;
            					  data_tmp_7 := data_tmp_5 and data_tmp_4;


              					for i in 0 to 21 loop
                					if(data_tmp_7(i) = '1') then
                  						data2_exp <= std_logic_vector(unsigned(data_in_2(30 downto 23)) - to_unsigned(i+1, 8));
						                data2_man(22 downto i + 1) <= data_in_2(21 - i downto 0);
						                data2_man( i downto 0) <= (others => '0');
                					end if;
              					end loop;

                				if(data_tmp_7(22) = '1') then
                  					data2_exp <= std_logic_vector(unsigned(data_in_2(30 downto 23)) - to_unsigned(23, 8));
						        data2_man <= (others => '0');
                				end if;

						  data2_sig <= data_in_2(31);
					else
						data_2_den <= '0';
						data2_sig <= data_in_2(31);
						data2_exp <= data_in_2(30 downto 23);
						data2_man <= data_in_2(22 downto 0);
					end if;

					valid_p1 <= in_valid;
				else
					data_1_den <= data_1_den;
					data1_sig <= data1_sig;
					data1_exp <= data1_exp;
					data1_man <= data1_man;

					data_2_den <= data_2_den;
					data2_sig <= data2_sig;
					data2_exp <= data2_exp;
					data2_man <= data2_man;

					valid_p1 <= valid_p1;
				end if;
			end if;
		end if;
	end process;

	p2: process(clk) -- check special numbers & calculate 
	begin
		if rising_edge(clk) then
			if rst = '1' then
				valid_p2 <= '0';
                                ans_exc <= '0';
			else
				if stall_p2 = '0' then
					if data1_sig = '0' and data1_exp = "00000000" and data1_man = "00000000000000000000000" and data_1_den = '0' then
						if data2_sig = '0' and data2_exp = "00000000" and data2_man = "00000000000000000000000"  and data_2_den = '0' then
							ans_sig <= '0';
							ans_exp <= "0000000000";
							ans_man <= "000000000000000000000000000000000000000000000000";
                                                        ans_exc <= '1';
						elsif data2_sig = '1' and data2_exp = "00000000" and data2_man = "00000000000000000000000"  and data_2_den = '0'  then
							ans_sig <= '1';
							ans_exp <= "0000000000";
							ans_man <= "000000000000000000000000000000000000000000000000";
                                                        ans_exc <= '1';
						elsif data2_exp = "11111111"  and data_2_den = '0'  then
							ans_sig <= '0';
							ans_exp <= "0011111111";
							ans_man <= "000000000000000000000000000000000000000000000001";
                                                        ans_exc <= '1';
						else
							ans_sig <= data1_sig xor data2_sig;
							ans_exp <= "0000000000";
							ans_man <= "000000000000000000000000000000000000000000000000";
                                                        ans_exc <= '1';
						end if;
					elsif data1_sig = '1' and data1_exp = "00000000" and data1_man = "00000000000000000000000" and data_1_den = '0' then
						if data2_sig = '0' and data2_exp = "00000000" and data2_man = "00000000000000000000000"   and data_2_den = '0' then
							ans_sig <= '1';
							ans_exp <= "0000000000";
							ans_man <= "000000000000000000000000000000000000000000000000";
                                                        ans_exc <= '1';
						elsif data2_sig = '1' and data2_exp = "00000000" and data2_man = "00000000000000000000000"   and data_2_den = '0' then
							ans_sig <= '0';
							ans_exp <= "0000000000";
							ans_man <= "000000000000000000000000000000000000000000000000";
                                                        ans_exc <= '1';
						elsif data2_exp = "11111111"   and data_2_den = '0' then
							ans_sig <= '0';
							ans_exp <= "0011111111";
							ans_man <= "000000000000000000000000000000000000000000000001";
                                                        ans_exc <= '1';
						else
							ans_sig <= data1_sig xor data2_sig;
							ans_exp <= "0000000000";
							ans_man <= "000000000000000000000000000000000000000000000000";
                                                        ans_exc <= '1';
						end if;
					elsif data1_sig = '0' and data1_exp = "11111111" and data1_man = "00000000000000000000000" and data_1_den = '0' then
						if data2_exp = "00000000" and data2_man = "00000000000000000000000"   and data_2_den = '0' then
							ans_sig <= '0';
							ans_exp <= "0011111111";
							ans_man <= "000000000000000000000000000000000000000000000001";
                                                        ans_exc <= '1';
						elsif data2_sig = '0' and data2_exp = "11111111" and data2_man = "00000000000000000000000"   and data_2_den = '0' then
							ans_sig <= '0';
							ans_exp <= "0011111111";
							ans_man <= "000000000000000000000000000000000000000000000000";
                                                        ans_exc <= '1';
						elsif data2_sig = '1' and data2_exp = "11111111" and data2_man = "00000000000000000000000"   and data_2_den = '0' then
							ans_sig <= '1';
							ans_exp <= "0011111111";
							ans_man <= "000000000000000000000000000000000000000000000000";
                                                        ans_exc <= '1';
						elsif data2_sig = '0' and data2_exp = "11111111" and data2_man /= "00000000000000000000000"   and data_2_den = '0' then
							ans_sig <= '0';
							ans_exp <= "0011111111";
							ans_man <= "000000000000000000000000000000000000000000000001";
                                                        ans_exc <= '1';
						elsif data2_sig = '1' and data2_exp = "11111111" and data2_man /= "00000000000000000000000"   and data_2_den = '0' then
							ans_sig <= '0';
							ans_exp <= "0011111111";
							ans_man <= "000000000000000000000000000000000000000000000001";
                                                        ans_exc <= '1';
						else
							ans_sig <= data1_sig xor data2_sig;
							ans_exp <= "0011111111";
							ans_man <= "000000000000000000000000000000000000000000000000";
                                                        ans_exc <= '1';
						end if;
					elsif data1_sig = '1' and data1_exp = "11111111" and data1_man = "00000000000000000000000" and data_1_den = '0' then
						if data2_exp = "00000000" and data2_man = "00000000000000000000000" and data_2_den = '0' then
							ans_sig <= '0';
							ans_exp <= "0011111111";
							ans_man <= "000000000000000000000000000000000000000000000001";
                                                        ans_exc <= '1';
						elsif data2_sig = '0' and data2_exp = "11111111" and data2_man = "00000000000000000000000" and data_2_den = '0' then
							ans_sig <= '1';
							ans_exp <= "0011111111";
							ans_man <= "000000000000000000000000000000000000000000000000";
                                                        ans_exc <= '1';
						elsif data2_sig = '1' and data2_exp = "11111111" and data2_man = "00000000000000000000000" and data_2_den = '0' then
							ans_sig <= '0';
							ans_exp <= "0011111111";
							ans_man <= "000000000000000000000000000000000000000000000000";
                                                        ans_exc <= '1';
						elsif data2_sig = '0' and data2_exp = "11111111" and data2_man /= "00000000000000000000000" and data_2_den = '0' then
							ans_sig <= '0';
							ans_exp <= "0011111111";
							ans_man <= "000000000000000000000000000000000000000000000001";
                                                        ans_exc <= '1';
						elsif data2_sig = '1' and data2_exp = "11111111" and data2_man /= "00000000000000000000000" and data_2_den = '0' then
							ans_sig <= '0';
							ans_exp <= "0011111111";
							ans_man <= "000000000000000000000000000000000000000000000001";
                                                        ans_exc <= '1';
						else
							ans_sig <= data1_sig xor data2_sig;
							ans_exp <= "0011111111";
							ans_man <= "000000000000000000000000000000000000000000000000";
                                                        ans_exc <= '1';
						end if;
					elsif data1_exp = "11111111" and data1_man /= "00000000000000000000000" and data_1_den = '0' then
							ans_sig <= '0';
							ans_exp <= "0011111111";
							ans_man <= "000000000000000000000000000000000000000000000001";
                                                        ans_exc <= '1';
					--data2 excepetion
					elsif data2_exp = "00000000" and data2_man = "00000000000000000000000" and data_2_den = '0' then
							ans_sig <= data1_sig xor data2_sig;
							ans_exp <= "0000000000";
							ans_man <= "000000000000000000000000000000000000000000000000";
                                                        ans_exc <= '1';
					elsif data2_exp = "11111111" and data2_man = "00000000000000000000000" and data_2_den = '0' then
							ans_sig <= data1_sig xor data2_sig;
							ans_exp <= "0011111111";
							ans_man <= "000000000000000000000000000000000000000000000000";
                                                        ans_exc <= '1';
					elsif data2_exp = "11111111" and data2_man /= "00000000000000000000000" and data_2_den = '0' then
							ans_sig <= '0';
							ans_exp <= "0011111111";
							ans_man <= "000000000000000000000000000000000000000000000001";
                                                        ans_exc <= '1';
					--no exception
					else
							ans_sig <= data1_sig xor data2_sig;		

							if(data_1_den = '1' and data_2_den = '1') then
								ans_exp <= unsigned("11" & data1_exp) + unsigned("11" & data2_exp) - bias + to_unsigned(1,10);    
							elsif(data_1_den = '1') then
								ans_exp <= unsigned("11" & data1_exp) + unsigned("00" & data2_exp) - bias + to_unsigned(1,10);     
							elsif(data_2_den = '1') then
								ans_exp <= unsigned("00" & data1_exp) + unsigned("11" & data2_exp) - bias + to_unsigned(1,10);    
							else			
								ans_exp <= unsigned("00" & data1_exp) + unsigned("00" & data2_exp) - bias;    
							end if;                                                  
							ans_man <= unsigned('1' & data1_man) * unsigned('1' & data2_man);
                                                        ans_exc <= '0';
					end if;
					valid_p2 <= valid_p1;
				else
					ans_sig <= ans_sig;
					ans_exp <= ans_exp;
					ans_man <= ans_man;
                                        ans_exc <= ans_exc;

					valid_p2 <= valid_p2;
				end if;
			end if;
		end if;
	end process;

	p3: process(clk) -- when carry, add '1' to exp
	begin
		if rising_edge(clk) then
			if rst = '1' then
				valid_p3 <= '0';
			else
				if stall_p3 = '0' then
                                        ans_sig_2 <= ans_sig;
                                        if(ans_man(47) = '1' and ans_exc = '0') then
				          ans_exp_2 <= to_unsigned(1,10) + ans_exp;
                                        else
					  ans_exp_2 <= ans_exp;
                                        end if;
					ans_man_2 <= ans_man;
                                        valid_p3 <= valid_p2;
				else
					ans_sig_2 <= ans_sig_2;
					ans_exp_2 <= ans_exp_2;
					ans_man_2 <= ans_man_2;

					valid_p3 <= valid_p3;
				end if;
			end if;
		end if;
	end process;

	out_valid 		<= valid_p3;  
	mant_out	  	<= ans_man_2;
    	exp_out 		<= ans_exp_2;
    	sign_out       		<= ans_sig_2;

end arch;
