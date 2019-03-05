--Engineer     : Xiaoting Lai, Dingxin Jin
--Date         : 10/1/2018
--Name of file : fpp_diviide.vhd
--Description  : Floating point divider

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity fpp_divide is
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
end fpp_divide;


architecture arch of fpp_divide is

         -- ********************** DEFINE SIGNALS **********************
	signal data1_sig, data_1_den: std_logic;
	signal data1_exp: std_logic_vector(7 downto 0);
	signal data1_man: std_logic_vector(22 downto 0);

	signal data2_sig, data_2_den: std_logic;
	signal data2_exp: std_logic_vector(7 downto 0);
	signal data2_man: std_logic_vector(22 downto 0);

	signal ans_sig, ans_exc: std_logic;
	signal ans_exp: unsigned(9 downto 0);

	signal ans_exp_2: unsigned(9 downto 0);
	signal ans_man_2: unsigned(23 downto 0);

	signal bias: unsigned(7 downto 0);
	signal borrow :unsigned(9 downto 0);
	signal q_out: unsigned (25 downto 0);

        signal div_count : unsigned(5 downto 0);
	--divide
		signal r     : unsigned (47 downto 0);
		signal d     : unsigned (47 downto 0);
		signal q     : unsigned (25 downto 0);

        
	type state is (ini, check, divide, finalize, output);
	signal current_state, next_state: state;
        

     begin


	bias <= to_unsigned(127,8);
	borrow <= to_unsigned(1,10);

--signal process
            process(clk)  
                begin
                  if (rising_edge(clk)) then
                    if (rst='1') then
                        current_state <= ini; 
                    else
                        current_state <= next_state;
                    end if;
                  end if;
            end process;
--            out_valid <= valid_p2; 
-- output
--            process(valid_p2)
--            begin   
--              if (valid_p2 = '1') then
--                 data_out <= result;
--              end if;
--            end process;


            process(current_state, in_valid, next_out, div_count)


	    begin
		case current_state is

		    --inilialize registers and normalize all denormalized numbers 
                    when ini => 



			if (in_valid = '1') then       --check valid signal
                                next_state <= check;
                                next_in    <= '0';
                        else
                                next_state <= ini;
                                next_in    <= '1';
                        end if;


		    --check all special case 
                    when check => 


			if data1_sig = '0' and data1_exp = "00000000" and data1_man = "00000000000000000000000" and data_1_den = '0' then  
				next_state <= finalize;
			elsif data1_sig = '1' and data1_exp = "00000000" and data1_man = "00000000000000000000000" and data_1_den = '0' then  
				next_state <= finalize;
			elsif data1_sig = '0' and data1_exp = "11111111" and data1_man = "00000000000000000000000" and data_1_den = '0' then  
				next_state <= finalize;
			elsif data1_sig = '1' and data1_exp = "11111111" and data1_man = "00000000000000000000000" and data_1_den = '0' then    
				next_state <= finalize;
			elsif data1_exp = "11111111" and data1_man /= "00000000000000000000000" and data_1_den = '0' then               
				next_state <= finalize;
					--data2 excepetion
			elsif data2_exp = "00000000" and data2_man = "00000000000000000000000" and data_2_den = '0' then                    
				next_state <= finalize;
			elsif data2_exp = "11111111" and data2_man = "00000000000000000000000" and data_2_den = '0' then                  
				next_state <= finalize;
			elsif data2_exp = "11111111" and data2_man /= "00000000000000000000000" and data_2_den = '0' then                  
				next_state <= finalize;
			--no exception
			else
				next_state <= divide;
                                                        
			end if;
			
                        next_in <= '0';


		    --divide
                    when divide => 
                          next_in    <= '0';
			if(div_count < to_unsigned(25,6)) then
                          next_state <= divide;
			else
                          next_state <= finalize;
			end if;

		    --finalize  
                    when finalize => 
                        next_state <= output;
                        next_in    <= '0';

                   when output => 
			
                        if (next_out = '0') then
                                next_state <= output;
                                next_in    <= '0';
                        else
                                next_state <= ini;
                                next_in    <= '1';
                        end if;
                          
                    end case;

            end process;
                     

	  state_output:process(clk) 
	--inilialize
		variable data_tmp_0 : unsigned(22 downto 0);
    		variable data_tmp_1 : unsigned(22 downto 0);
	   	variable data_tmp_2 : unsigned(22 downto 0);
    		variable data_tmp_3 : unsigned(22 downto 0);
    		variable data_tmp_4 : unsigned(22 downto 0);
    		variable data_tmp_5 : unsigned(22 downto 0);
   		variable data_tmp_6 : unsigned(22 downto 0);
    		variable data_tmp_7 : unsigned(22 downto 0);
          begin
		if(rising_edge(clk)) then
			if(rst ='1') then
				data_2_den <= '0';
				data2_exp <= (others =>'0');
				data2_man <= (others =>'0');
				data2_sig <= '0';
				data_1_den <= '0';
				data1_exp <= (others =>'0');
				data1_man <= (others =>'0');
				data1_sig <= '0';

				mant_out <= (others =>'0');
				exp_out <= (others =>'0');
				sign_out <= '0';
				ans_man_2 <= (others =>'0');
				ans_exp_2 <= (others =>'0');
				ans_sig <= '0';
				ans_exp <= (others =>'0');
				ans_exc <= '0';
				
				q_out <= (others =>'0');
                                out_valid  <= '0'; 
				div_count <= (others =>'0');
		else
		case current_state is
		when ini => 
                                out_valid  <= '0'; 
			if(data_in_1(30 downto 23) = "00000000" and data_in_1(22 downto 0) /= "00000000000000000000000") then    --if data_in_1 is denormalized
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

					
			if(data_in_2(30 downto 23) = "00000000" and data_in_2(22 downto 0) /= "00000000000000000000000") then    --if data_in_2 is denormalized
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
				data2_sig  <= data_in_2(31);
				data2_exp  <= data_in_2(30 downto 23);
				data2_man  <= data_in_2(22 downto 0);
			end if;

                    when check => 
                                out_valid  <= '0'; 


			if data1_sig = '0' and data1_exp = "00000000" and data1_man = "00000000000000000000000" and data_1_den = '0' then  --  data1 = +0
				if data2_exp = "00000000" and data2_man = "00000000000000000000000"  and data_2_den = '0' then -- +0 / +-0 = QNaN
					ans_sig <= '0';
					ans_exp <= "0011111111";
					q    <= "00000000000000000000000001";
                                        ans_exc <= '1';  --change to current_state <= output;
				elsif data2_exp = "11111111"  and data2_man = "00000000000000000000000"  and data_2_den = '0'  then -- +0 / +-oo = +-0
					ans_sig <= data1_sig xor data2_sig;
					ans_exp <= "0000000000";
					q    <="00000000000000000000000000";
                                        ans_exc <= '1';						
				elsif data2_exp = "11111111"  and data2_man /= "00000000000000000000000"  and data_2_den = '0'  then -- +0 / +-NaN = QNan
					ans_sig <= '0';
					ans_exp <= "0011111111";
					q    <= "00000000000000000000000001";
                                        ans_exc <= '1';                          
				else                                                                                                 -- +0 / +-others  = +-0
					ans_sig <= data1_sig xor data2_sig;
					ans_exp <= "0000000000";
					q    <= "00000000000000000000000000";
                                        ans_exc <= '1';
				end if;
			elsif data1_sig = '1' and data1_exp = "00000000" and data1_man = "00000000000000000000000" and data_1_den = '0' then  -- data1 = -0
				if data2_exp = "00000000" and data2_man = "00000000000000000000000"  and data_2_den = '0' then -- -0 / +-0 = QNaN
					ans_sig <= '0';
					ans_exp <= "0011111111";
					q    <= "00000000000000000000000001";
                                        ans_exc <= '1';
				elsif data2_exp = "11111111"  and data2_man = "00000000000000000000000"  and data_2_den = '0'  then -- -0 / +-oo = -+0
					ans_sig <= data1_sig xor data2_sig;
					ans_exp <= "0000000000";
					q    <= "00000000000000000000000000";
                                        ans_exc <= '1';						
				elsif data2_exp = "11111111"  and data2_man /= "00000000000000000000000"  and data_2_den = '0'  then -- -0 / +-NaN = QNan
					ans_sig <= '0';
					ans_exp <= "0011111111";
					q    <= "00000000000000000000000001";
                                        ans_exc <= '1';                          
				else                                                                                                 -- -0 / +-others  = -+0
					ans_sig <= data1_sig xor data2_sig;
					ans_exp <= "0000000000";
					q    <= "00000000000000000000000000";
                                        ans_exc <= '1';
				end if;
			elsif data1_sig = '0' and data1_exp = "11111111" and data1_man = "00000000000000000000000" and data_1_den = '0' then  -- data1 = +oo
				if data2_exp = "00000000" and data2_man = "00000000000000000000000"   and data_2_den = '0' then      -- +oo / +-0 = +-oo
					ans_sig <= data1_sig xor data2_sig;
					ans_exp <= "0011111111";
					q    <= "00000000000000000000000000";
                                        ans_exc <= '1';
				elsif data2_exp = "11111111" and data2_man = "00000000000000000000000"   and data_2_den = '0' then   -- +oo / +-oo = QNaN
					ans_sig <= '0';
					ans_exp <= "0011111111";
					q    <= "00000000000000000000000001";
                                        ans_exc <= '1';
				elsif data2_exp = "11111111" and data2_man /= "00000000000000000000000"   and data_2_den = '0' then   -- +oo / +-Nan = QNaN
					ans_sig <= '0';
					ans_exp <= "0011111111";
					q    <= "00000000000000000000000001";
                                        ans_exc <= '1';
				else                                                                                                  -- +oo / +-others = +-oo
					ans_sig <= data1_sig xor data2_sig;
					ans_exp <= "0011111111";
					q    <= "00000000000000000000000000";
                                        ans_exc <= '1';
				end if;
			elsif data1_sig = '1' and data1_exp = "11111111" and data1_man = "00000000000000000000000" and data_1_den = '0' then    -- data1 = -oo
				if data2_exp = "00000000" and data2_man = "00000000000000000000000"   and data_2_den = '0' then      -- -oo / +-0 = -+oo
					ans_sig <= data1_sig xor data2_sig;
					ans_exp <= "0011111111";
					q    <= "00000000000000000000000000";
                                        ans_exc <= '1';
				elsif data2_exp = "11111111" and data2_man = "00000000000000000000000"   and data_2_den = '0' then   -- -oo / +-oo = QNaN
					ans_sig <= '0';
					ans_exp <= "0011111111";
					q    <= "00000000000000000000000001";
                                        ans_exc <= '1';
				elsif data2_exp = "11111111" and data2_man /= "00000000000000000000000"   and data_2_den = '0' then   -- -oo / +-Nan = QNaN
					ans_sig <= '0';
					ans_exp <= "0011111111";
					q    <= "00000000000000000000000001";
                                        ans_exc <= '1';
				else                                                                                                  -- -oo / +-others = -+oo
					ans_sig <= data1_sig xor data2_sig;
					ans_exp <= "0011111111";
					q    <= "00000000000000000000000000";
                                        ans_exc <= '1';
				end if;
			elsif data1_exp = "11111111" and data1_man /= "00000000000000000000000" and data_1_den = '0' then               -- data1 = +-NaN
				ans_sig <=  '0';                                                           -- +-Nan / anything = QNaN
				ans_exp <= "0011111111";
				q    <= "00000000000000000000000001";
                                ans_exc <= '1';
					--data2 excepetion
			elsif data2_exp = "00000000" and data2_man = "00000000000000000000000" and data_2_den = '0' then                     --data2 = +- 0
				ans_sig <= data1_sig xor data2_sig;                                             -- others / +-0  = +-oo
				ans_exp <= "0011111111";
				q    <= "00000000000000000000000000";
                                ans_exc <= '1';
			elsif data2_exp = "11111111" and data2_man = "00000000000000000000000" and data_2_den = '0' then                   -- data2 = +-oo
				ans_sig <= data1_sig xor data2_sig;                                             -- others / +-oo  = +-0                    
				ans_exp <= "0000000000";
				q    <= "00000000000000000000000000";
                                ans_exc <= '1';
			elsif data2_exp = "11111111" and data2_man /= "00000000000000000000000" and data_2_den = '0' then                  -- data2 = +-NaN
				ans_sig <= '0';                                                                 -- others / +-NaN  = QNaN  
				ans_exp <= "0011111111";
				q    <= "00000000000000000000000001";
                                ans_exc <= '1';
			else
				ans_sig <= data1_sig xor data2_sig;		

				if(data_1_den = '1' and data_2_den = '1') then
					ans_exp <= unsigned("11" & data1_exp) - unsigned("11" & data2_exp) + bias; -- + to_unsigned(1,10);    
				elsif(data_1_den = '1') then
					ans_exp <= unsigned("11" & data1_exp) - unsigned("00" & data2_exp) + bias + to_unsigned(1,10);     
				elsif(data_2_den = '1') then
					ans_exp <= unsigned("00" & data1_exp) - unsigned("11" & data2_exp) + bias - to_unsigned(1,10);    
				else			
					ans_exp <= unsigned("00" & data1_exp) - unsigned("00" & data2_exp) + bias;    
				end if;                                                  
				q                      <= (others => '0');                                             --quotient
				d                      <= '1' & unsigned(data2_man) & "000000000000000000000000";      --divisor
				r                      <= '1' & unsigned(data1_man) & "000000000000000000000000";      --remain
                                ans_exc <= '0';
				div_count <= to_unsigned(0,6);
			end if;
                    when divide => 
				div_count <= div_count + to_unsigned(1,6);
                                out_valid  <= '0'; 
				if (r<d) then
					q    <= q(24 downto 0) & '0';
 				else
					r    <= r - d;
					q    <= q(24 downto 0) & '1';
				end if;
					d    <= '0' & d(47 downto 1);

		when finalize => 
                                out_valid  <= '0'; 
			q_out      <= q;
			if (ans_exc = '1') then
				ans_exp_2 <= ans_exp;
				ans_man_2 <= q(23 downto 0);
			else
				
	                      	if(q(25) = '0') then --N < D
					ans_exp_2 <= ans_exp - borrow;
					if (q(0) = '1') then
						if(ans_exp(7 downto 0) = "0000000000"  or ans_exp(7 downto 0) = "111111111"or ans_exp(9) = '1'  or ans_exp(9 downto 8) = "01" or ans_exp = "000000000001") then
							ans_man_2 <= q(24 downto 1);
						else						
							ans_man_2 <= q(24 downto 1) + to_unsigned(1,23);
						end if;
					else
						ans_man_2 <= q(24 downto 1);
					end if;

				else
					ans_exp_2 <= ans_exp;
					if (q(1) = '1') then
						if(ans_exp(7 downto 0) = "0000000000"  or ans_exp(7 downto 0) = "111111111" or ans_exp(9) = '1' or ans_exp(9 downto 8) = "01") then 
							ans_man_2 <= q(25 downto 2);	
						else		
							ans_man_2 <= q(25 downto 2) + to_unsigned(1,23);	
						end if;
					else
						ans_man_2 <= q(25 downto 2);
					end if;
        	                end if;

			end if;
                   when output => 
			sign_out <= ans_sig;
			mant_out(23 downto 0) <= ans_man_2;  
			mant_out(47 downto 24) <= (others=>'0');  
			exp_out <= ans_exp_2;                       
			 if (next_out = '0') then
                                out_valid  <= '0'; 
                        else
                                out_valid  <= '1'; 
                        end if;
		end case;
		 end if;
		end if;
          end process;
        end arch;