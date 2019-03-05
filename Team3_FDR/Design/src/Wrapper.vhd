
--Engineer     : Dingxin Jin
--Date         : 11/20/2018
--Name of file : Wrapper.vhd
--Description  : Integrate function block for verification and synthesize

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;




entity Wrapper is
  port (
        -- input side
        clk, rst      : in  std_logic;
        next_in       : out std_logic;      
        in_valid      : in  std_logic;  
        ctr           : in  unsigned(1 downto 0);
	data_in_1     : in  std_logic_vector(31 downto 0);
        data_in_2     : in  std_logic_vector(31 downto 0);

        -- output side
	next_out      : in  std_logic;
        out_valid     : out std_logic;
        data_out      : out std_logic_vector(31 downto 0)
       );
end Wrapper;
-- DO NOT MODIFY PORT NAMES ABOVE

architecture arch of Wrapper is
  component FP_mult
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
  end component;

  component fpp_divide
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
  end component;

  component adder 
    port (
        -- input side
        clk, rst      : in std_logic;
        next_in       : out std_logic;      
        in_valid      : in std_logic;  
	data_in_1     : in std_logic_vector(31 downto 0);
        data_in_2     : in std_logic_vector(31 downto 0);

        -- output side
	next_out      : in  std_logic;
        out_valid     : out std_logic;
        data_out      : out std_logic_vector(31 downto 0)
       );
  end component;

  component Normalization 
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
  end component;
--I/P 
signal ctl_reg           : unsigned(1 downto 0);
--MULT
signal in_valid_1        : std_logic;  
signal next_in_reg_1     : std_logic; 
--DIVI 
signal in_valid_2        : std_logic;   
signal next_in_reg_2     : std_logic;  
--ADD
signal in_valid_3        : std_logic;   
signal next_in_reg_3     : std_logic;  

--O/P
--ADD
signal data_out_3      : std_logic_vector(31 downto 0);
signal out_valid_3     : std_logic;
--MULT&DIVI
signal data_out_4      : std_logic_vector(31 downto 0);
signal out_valid_4     : std_logic;

signal tmp_next_out   : std_logic;
signal tmp_out_valid  : std_logic;
signal tmp_mant_out   : unsigned(47 downto 0);
signal tmp_exp_out    : unsigned(9 downto 0); 
signal tmp_sign_out   : std_logic;
--MULT
signal tmp_mant_out_1  : unsigned(47 downto 0); 
signal tmp_exp_out_1   : unsigned(9 downto 0); 
signal tmp_sign_out_1  : std_logic; 
signal tmp_out_valid_1 : std_logic; 
--DIVI
signal tmp_mant_out_2  : unsigned(47 downto 0); 
signal tmp_exp_out_2   : unsigned(9 downto 0); 
signal tmp_sign_out_2  : std_logic; 
signal tmp_out_valid_2 : std_logic;  
begin


  ctl_reg       <= ctr;
  next_in <= next_in_reg_1 and next_in_reg_2 and next_in_reg_3;

  --"00":*
  --"01":/
  --"10":+ and -
  MUX: process(ctl_reg, in_valid, data_out_4, out_valid_4, data_out_3, out_valid_3,tmp_out_valid_1, tmp_out_valid_2, tmp_mant_out_1, tmp_mant_out_2,tmp_exp_out_1,tmp_exp_out_2, tmp_sign_out_1, tmp_sign_out_2 ) 
  begin
    case ctl_reg is
          when "00" => in_valid_1 <= in_valid;                          
                        in_valid_2 <= '0';     
			in_valid_3 <= '0';
                        tmp_out_valid <= tmp_out_valid_1;    
                        tmp_mant_out  <= tmp_mant_out_1;   
                        tmp_exp_out   <= tmp_exp_out_1;    
                        tmp_sign_out  <= tmp_sign_out_1;   			
			data_out  <= data_out_4;
			out_valid <= out_valid_4;

          when "01" => in_valid_1 <= '0';                         
                        in_valid_2 <= in_valid; 
			in_valid_3 <= '0';
                        tmp_out_valid <= tmp_out_valid_2;    
                        tmp_mant_out  <= tmp_mant_out_2;   
                        tmp_exp_out   <= tmp_exp_out_2;    
                        tmp_sign_out  <= tmp_sign_out_2; 			
			data_out  <= data_out_4;
			out_valid <= out_valid_4;

          when "10" => in_valid_1 <= '0';                               
                        in_valid_2 <= '0'; 
			in_valid_3 <= in_valid;
                        tmp_out_valid <= '0';    
                        tmp_mant_out  <= (others => '0');   
                        tmp_exp_out   <= (others => '0');    
                        tmp_sign_out  <= '0';  		
			data_out  <= data_out_3;
			out_valid <= out_valid_3;

          when "11" => in_valid_1 <= '0';                               
                        in_valid_2 <= '0';
			in_valid_3 <= '0';
                        tmp_out_valid <= '0';        
                        tmp_mant_out  <= (others => '0');   
                        tmp_exp_out   <= (others => '0');    
                        tmp_sign_out  <= '0';     			
			data_out  <= (others => '0');
			out_valid <= '0';

          when others => in_valid_1 <= '0';                               
                        in_valid_2 <= '0';
			in_valid_3 <= '0';
                        tmp_out_valid <= '0';      
                        tmp_mant_out  <= (others => '0');   
                        tmp_exp_out   <= (others => '0');    
                        tmp_sign_out  <= '0';     
			data_out  <= (others => '0');
			out_valid <= '0';
    end case;     
  end process;


  Mult: FP_mult
  port map (
    clk           => clk,
    rst           => rst,
    next_in       => next_in_reg_1,
    in_valid      => in_valid_1,    
    data_in_1  	  => data_in_1,
    data_in_2     => data_in_2,
    next_out      => tmp_next_out,
    out_valid     => tmp_out_valid_1,
    mant_out      => tmp_mant_out_1,
    exp_out       => tmp_exp_out_1,
    sign_out      => tmp_sign_out_1

           );

  Divide: fpp_divide
  port map (
    clk           => clk,
    rst           => rst,
    next_in       => next_in_reg_2,
    in_valid      => in_valid_2,    
    data_in_1  	  => data_in_1,
    data_in_2     => data_in_2,
    next_out      => tmp_next_out,
    out_valid     => tmp_out_valid_2,
    mant_out      => tmp_mant_out_2,
    exp_out       => tmp_exp_out_2,
    sign_out      => tmp_sign_out_2
           );

  Add: adder
  port map (
    clk           => clk,
    rst           => rst,
    next_in       => next_in_reg_3,
    in_valid      => in_valid_3,    
    data_in_1  	  => data_in_1,
    data_in_2     => data_in_2,
    next_out      => next_out,
    out_valid     => out_valid_3,
    data_out      => data_out_3

           );

  Norm: Normalization
  port map (
    clk           => clk,
    rst        	  => rst,
    next_in      => tmp_next_out,
    in_valid     => tmp_out_valid,
    mant_in      => tmp_mant_out,
    exp_in       => tmp_exp_out,
    sign_in      => tmp_sign_out,

    next_out      => next_out,
    out_valid     => out_valid_4,
    data_out      => data_out_4

           );
end arch;