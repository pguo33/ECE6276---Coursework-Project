--Engineer     : Peng Guo, Dingxin Jin
--Date         : 12/01/2018
--Name of file : adder.vhd
--Description  : Floating point adder

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    
    entity adder is
        port (clk, rst             : in std_logic;
              data_in_1, data_in_2 : in std_logic_vector(31 downto 0);
              data_out             : out std_logic_vector(31 downto 0);
              next_out             : in std_logic;
              next_in              : out std_logic;
              in_valid             : in std_logic;
              out_valid            : out std_logic);
    end adder;
    
    architecture adder_arch of adder is
        --seq
        signal valid_p1: std_logic;
        signal stall_p1: std_logic;
        signal valid_p2: std_logic;
        signal result: std_logic_vector(31 downto 0);
        --state A
        signal nan: std_logic;
        signal exponent_difference, shift_right_pos: integer;
        signal exp_1, exp_2 : integer;
        --state B
        signal large_exp_ctrl, small_no_ctrl, large_no_ctrl: std_logic;
        signal addsub, sign_out: std_logic;
        --state C
        signal small_significand, large_significand: std_logic_vector(23 downto 0);
        signal large_exponent: std_logic_vector (7 downto 0);
        --state D
        signal small_significand_shifted: std_logic_vector(26 downto 0);
        signal large_grs_significand: std_logic_vector(26 downto 0);
        --state E
        signal initial_sum: std_logic_vector(27 downto 0);
        signal fraction_final: std_logic_vector (24 downto 0);
        signal exponent_out_final: std_logic_vector (7 downto 0);
        --state F
        signal exp_ctrl, shift_fraction_ctrl, end_ctrl: std_logic;
        signal positions: integer;
        --state G
        signal ovf, unf: std_logic;
        signal sum: std_logic_vector(27 downto 0);
        signal expon_mux: std_logic_vector (7 downto 0);
        --state H
        signal exponent_out: std_logic_vector (7 downto 0);
        signal sum_shifted: std_logic_vector(26 downto 0);
        signal fraction_fin_sig: std_logic_vector (24 downto 0);
        
        type state is (A, B, C, D, E, F, G, H, AI, J);
        signal current_state, next_state: state;
        
        begin
            process(clk)  
                begin
                  if (rising_edge(clk)) then
                    if (rst='1') then
                        --valid_p1 <= '0';
                        current_state <= A; 
                                
                
                    else
                        --valid_p1 <= in_valid;
                        --if (in_valid = '1') then
                           current_state <= next_state;
                      --  end if;
                    end if;
                  end if;
            end process;
             
-- Stall Signal
--stall_p1 <= valid_p1 and (not next_out);

-- next_in & out_valid
 --           process(valid_p1, current_state,stall_p1)
  --          begin
  ----            if (valid_p1 = '0') then
     --            next_in <= not stall_p1;
       --          valid_p2 <= valid_p1;
         --     else
           --     if (current_state = J) then
             --      next_in <= not stall_p1;
 --                  valid_p2 <= valid_p1;
   --             else
     --              next_in <= '0';
       --            valid_p2 <= '0';
         --       end if;
           --   end if;
           -- end process;
            out_valid <= valid_p2; 
            data_out <= result;

-- data_out

            process(current_state, in_valid, fraction_fin_sig, next_out)
                
                                
                begin
                   case current_state is
                                                 --nan checker
                       when A => 
                                if (in_valid = '1') then
                                     next_state <= B;
                                     next_in <= '0';
                                 else
                                     next_state <= A;
                                     next_in <= '1';
                                 end if;

                                 --find a large exponent
                      when B =>   
            
                                next_state <= C;
                                 next_in <= '0';                              
                                --small fraction mux
                      when C => 
                          
                                next_state <= D;
                                 next_in <= '0';
                                --GRS = 000
                      when D => 
                                
                                next_state <= E;
                                 next_in <= '0';                            
                              --big alu  
                    when E => 
                               
                               next_state <= F;
                                 next_in <= '0';                              
                              --normalize control

                    when F => 
                               
                               next_state <= G;
                                 next_in <= '0';                            
                              --of uf infinity check 
                    when G => 
                      
                               next_state <= H;
                                 next_in <= '0';                             
                              --incr_dec
                    when H => 
                               
                               next_state <= AI;
                                 next_in <= '0';                     
                              --rounding
                    when AI => 
                                 next_in <= '0';
                               if fraction_fin_sig(24) = '1' then
                                   next_state <= F;
                               else 
                                   next_state <= J;
                               end if;
                             
                               --out
                    when J =>
                              if (next_out = '0') then
                                  next_state <= J;
                                  next_in <= '0';
                              else
                                  next_state <= A;
                                  next_in <= '1';
                              end if;
                          
                           end case;
            end process;
            output_state: process (clk)                
                --state D
                variable small_grs_significand: std_logic_vector (26 downto 0);
                variable shifter: std_logic_vector (26 downto 0);
                variable decider: integer;
                --state F
                variable n,i: integer;
                --state H
                variable sum_sh: std_logic_vector (27 downto 0);
                --state AI
                variable fraction_fin: std_logic_vector (24 downto 0);
	    begin
		if(rising_edge(clk)) then
		if(rst ='1') then
				nan <= '0';
				exp_1 <=  0;
				exp_2 <=  0;
				exponent_difference <= 0;    
  
                                large_exp_ctrl <= '0';
                                small_no_ctrl <= '0';
                                large_no_ctrl <= '0';
                                sign_out <= '0';
				shift_right_pos <= 0;    
				addsub <='0';
				small_significand <= (others=>'0');
				large_significand <= (others=>'0');
				large_exponent <= (others=>'0');

				large_grs_significand <= (others=>'0');
				small_significand_shifted <= (others=>'0');

				initial_sum <= (others=>'0');
				fraction_final <= (others=>'0');
				exponent_out_final <= (others=>'0');

				end_ctrl <= '0';
				shift_fraction_ctrl <= '0';
				exp_ctrl <= '0';
				 positions <= 0;

				unf <= '0';
				ovf <= '0';
				sum <= (others=>'0');
				expon_mux <= (others=>'0');
                                   
				exponent_out <= "00000000";
				sum_shifted <= "000000000000000000000000000";
                fraction_fin_sig <= (others => '0');

				result <= (others=>'0');
                                valid_p2 <= '0';
		else
		fraction_fin_sig <= fraction_fin;
		case current_state is
		when A =>  valid_p2 <= '0';
				if ((data_in_1(30 downto 23) = "11111111") and (data_in_2(30 downto 23) = "11111111") and (data_in_1(31) /= data_in_2(31))) then
                                     nan <= '1';
                                 elsif ((data_in_1(30 downto 23) = "11111111") and (data_in_1(22 downto 0)/="00000000000000000000000")) then
                                     nan <= '1';
                                 elsif ((data_in_2(30 downto 23) = "11111111") and (data_in_2(22 downto 0)/="00000000000000000000000")) then
                                     nan <= '1';
                                 else
                                     nan <= '0';
                                 end if;
                                 exp_1 <= to_integer(unsigned(data_in_1(30 downto 23)));
                                 exp_2 <= to_integer(unsigned(data_in_2(30 downto 23)));
                                 --shift bits
                                 --exponent_difference <= exp_1 - exp_2;   
                                 exponent_difference <= to_integer(unsigned(data_in_1(30 downto 23))) - to_integer(unsigned(data_in_2(30 downto 23)));  
		when B =>   valid_p2 <= '0';
				if (exponent_difference > 0) then            
                                    large_exp_ctrl <= '1';
                                    small_no_ctrl <= '0';
                                    large_no_ctrl <= '1';
                                    shift_right_pos <= exponent_difference;
                                    if (nan = '1') then
                                       sign_out <= '0';
                                    else
                                       sign_out <= data_in_1(31); --result sign
                                    end if;
                                elsif (exponent_difference < 0) then
                                    large_exp_ctrl <= '0';
                                    small_no_ctrl <= '1'; 
                                    large_no_ctrl <= '0';
                                    shift_right_pos <= (0 - exponent_difference);
                                    if (nan = '1') then
                                       sign_out <= '0';
                                    else
                                       sign_out <= data_in_2(31); --result sign
                                    end if;
                                else
                                    large_exp_ctrl <= '0';
                                    shift_right_pos <= 0;
                                    if (nan = '1') then
                                       sign_out <= '0';
                                    elsif (data_in_1(22 downto 0) > data_in_2(22 downto 0)) then
                                       small_no_ctrl <= '0';
                                       large_no_ctrl <= '1';
                                       sign_out <= data_in_1(31); --result sign
                                    elsif (data_in_1(22 downto 0) < data_in_2(22 downto 0)) then
                                       small_no_ctrl <= '1';
                                       large_no_ctrl <= '0';
                                       sign_out <= data_in_2(31); --result sign
                                    else
                                       sign_out <= data_in_1(31) and data_in_2(31); --result sign
                                    end if;
                                end if;

                                --same sign or not
                                if (data_in_1(31)=data_in_2(31)) then
                                    addsub <= '0';
                                else
                                    addsub <= '1';
                                end if;     
		when C => valid_p2 <= '0';
				if (small_no_ctrl='1') then
                                   if (data_in_1(30 downto 23) = "00000000") then
                                       small_significand <= ('0' & data_in_1(22 downto 0));    
                                   else        
                                       small_significand <= ('1' & data_in_1(22 downto 0));
                                   end if;
                                else
                                   if (data_in_2(30 downto 23) = "00000000") then
                                       small_significand <= ('0' & data_in_2(22 downto 0));    
                                   else        
                                       small_significand <= ('1' & data_in_2(22 downto 0));
                                   end if;
                                end if;
                                
                                --large fraction mux
                                if (large_no_ctrl='1') then
                                   if (data_in_1(30 downto 23) = "00000000") then
                                       large_significand <= ('0' & data_in_1(22 downto 0));    
                                   else        
                                       large_significand <= ('1' & data_in_1(22 downto 0));
                                   end if;
                                else
                                   if (data_in_2(30 downto 23) = "00000000") then
                                       large_significand <= ('0' & data_in_2(22 downto 0));    
                                   else        
                                       large_significand <= ('1' & data_in_2(22 downto 0));
                                   end if;
                                end if;
                                
                                --large expo mux
                                if (large_exp_ctrl='1') then
                                    large_exponent <= data_in_1(30 downto 23); 
                                else
                                    large_exponent <= data_in_2(30 downto 23);
                                end if;
		when D => valid_p2 <= '0';
				small_grs_significand :=  small_significand & "000";    
                                large_grs_significand <=  large_significand & "000";
                                
                                --right shift
                                if (shift_right_pos < 27) then  
                                for i in 0 to 26 loop
                                  if(shift_right_pos = i) then         
                                    decider := to_integer(unsigned(small_grs_significand(i downto 0)));
                                  end if;
                                end loop;                    
                                    
                                elsif (small_grs_significand = "000000000000000000000000000") then
                                    decider := 0;
                                else 
                                    decider := 0;
                                end if;
                          
				if (data_in_1(30 downto 23) = "00000000" and data_in_2(30 downto 23) = "00000000" ) then
				  shifter := std_logic_vector(unsigned(small_grs_significand) srl shift_right_pos);
                                elsif (data_in_1(30 downto 23) = "00000000" or data_in_2(30 downto 23) = "00000000" ) then
                                  shifter := std_logic_vector(unsigned(small_grs_significand) srl (shift_right_pos - 1));
                                else
                                  shifter := std_logic_vector(unsigned(small_grs_significand) srl shift_right_pos);
                                end if;
                           
                                if (decider > 0) then
                                   small_significand_shifted <= (shifter(26 downto 1) & '1');
                                else 
                                   small_significand_shifted <= (shifter(26 downto 1) & '0');
                                end if;
  		when E => valid_p2 <= '0';
			if (addsub = '0') then              
                                   initial_sum <= std_logic_vector(unsigned('0'&large_grs_significand) + unsigned('0'&small_significand_shifted));
                               else
                                   initial_sum <= std_logic_vector(unsigned('0'&large_grs_significand) - unsigned('0'&small_significand_shifted));
                               end if;
                               
                               --arxikopoihsh aparaithtwn
                               fraction_final <= (others=>'0');
                               exponent_out_final <= (others=>'0');
                           
                              --normalize control

                    when F => valid_p2 <= '0';
				if (fraction_final(24) = '1') then     
                                   end_ctrl <= '1';
                               else 
                                   end_ctrl <= '0';
                               end if;
                               
                               if  ((initial_sum(27) = '1') or (fraction_final(24) = '1') or initial_sum(26 downto 0) = "111111111111111111111111101" or  initial_sum(26 downto 0) = "111111111111111111111111110" or initial_sum(26 downto 0) = "111111111111111111111111111") then
                                    shift_fraction_ctrl <= '1';
                                    exp_ctrl <= '1';
                                    positions <= 1;
                               else
                                    shift_fraction_ctrl <= '0';
                                    exp_ctrl <= '0';
                                    n := 0;                  
                                    for i in 0 to 27 loop                       
                                          if (initial_sum(i)='1') then
                                              n := i;
                                          else 
                                              n := n;
                                          end if;
                                    end loop;
                                    positions <= 27 - n;
                               end if;
                          
                              --of uf infinity check 
                    when G => valid_p2 <= '0';
				if ((exp_ctrl = '0') and (to_integer(unsigned(large_exponent)) - positions < 0)) then
                                   unf <= '1';
                               else
                                   unf <= '0';
                               end if; 
            
                               if ((exp_ctrl = '1') and (to_integer(unsigned(large_exponent)) + positions >= 255)) or (large_exponent = "11111111") then
                                   ovf <= '1';
                               else
                                   ovf <= '0';
                               end if; 
                               
                               --norm expo + significant mux
                               if (end_ctrl = '1') then           
                                   sum <= fraction_final & "000";
                                   expon_mux <= exponent_out_final;
                               else 
                                   sum <= initial_sum;
                                   expon_mux <= large_exponent;
                               end if;
                                                   
                              --incr_dec
                    when H => valid_p2 <= '0';
				if (nan='1' or ovf = '1') then            
                                   exponent_out <= "11111111";
                               elsif (exp_ctrl='0' and positions=27 and ovf = '0') then
                                   exponent_out <= "00000000";
                               elsif (exp_ctrl='1' and ovf = '0') then
                                   exponent_out <= std_logic_vector(unsigned(expon_mux) + to_unsigned(positions,8));
                               elsif (exp_ctrl='0' and unf = '0') then
                                   exponent_out <= std_logic_vector(unsigned(expon_mux) - to_unsigned(positions,8) + to_unsigned(1,8));
                               else 
                                   exponent_out <= "00000000";
                               end if; 
                               
                               --shift_left_right
                               if (shift_fraction_ctrl='1' and ovf = '0') then
                                   sum_sh := std_logic_vector(unsigned(sum) srl positions);
                               elsif (shift_fraction_ctrl='0' and unf = '0') then
                                   sum_sh := std_logic_vector(unsigned(sum) sll positions);
                               elsif (shift_fraction_ctrl='0' and unf = '1') then
                                   sum_sh := std_logic_vector(unsigned(sum) sll (to_integer(unsigned(large_exponent))) + 1);
                               end if;
                               
                               if (nan='1') then             
                                   sum_shifted <= "010000000000000000000000001";
                               elsif (ovf = '1') then
                                   sum_shifted <= "000000000000000000000000000";
                               elsif (shift_fraction_ctrl='1') then
                                   sum_shifted <= sum_sh(26 downto 0);
                               else
                                   sum_shifted <= sum_sh(27 downto 1); 
                               end if;
                                                   
                              --rounding
                    when AI => valid_p2 <= '0';
				if (nan = '1') then
                                   fraction_fin := sum_shifted(24 downto 0);
                               elsif (ovf = '1' and nan='0') then         
                                   fraction_fin := (others => '0');
                               elsif (sum_shifted(2)='0') then
                                   fraction_fin := '0' & sum_shifted(26 downto 3);
                               elsif (sum_shifted(2)='1' and ((sum_shifted(1) or sum_shifted(0)) = '1')) then
                                   fraction_fin := std_logic_vector(unsigned('0' & sum_shifted(26 downto 3)) + 1);
                               elsif (sum_shifted(2 downto 0)="100" and sum_shifted(3)='0') then
				   if(initial_sum(0) = '1') then
                                     fraction_fin := '0' & sum_shifted(26 downto 4) & '1';
                                   else
                                     fraction_fin := '0' & sum_shifted(26 downto 3);
                                   end if;
                               else 
                                   fraction_fin := std_logic_vector(unsigned('0' & sum_shifted(26 downto 3)) + 1);
                               end if;
                               
                               exponent_out_final <= exponent_out;
                               fraction_final <= fraction_fin;
                             
                               --out
                    when J => result <= sign_out & exponent_out_final & fraction_final(22 downto 0);   
                              if (next_out = '0') then
                                  valid_p2 <= '0'; 
                              else
                                  valid_p2 <= '1'; 
                              end if;
		end case;
	      end if; 
	    end if;
            end process;
        end adder_arch;
