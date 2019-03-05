
--Engineer     : Shengwei Lyu, Dingxin Jin
--Date         : 11/20/2018
--Name of file : Wrapper.vhd
--Description  : Integrate function block for verification and synthesize

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;




entity Mult_Wrapper is
  port (
        -- input side
        clk, rst      : in  std_logic;
        next_in       : out std_logic;      
        in_valid      : in  std_logic;  
	data_in_1     : in  std_logic_vector(31 downto 0);
        data_in_2     : in  std_logic_vector(31 downto 0);

        -- output side
	next_out      : in  std_logic;
        out_valid     : out std_logic;
        data_out      : out std_logic_vector(31 downto 0)
       );
end Mult_Wrapper;
-- DO NOT MODIFY PORT NAMES ABOVE

architecture arch of Mult_Wrapper is
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

signal tmp_mant_out : unsigned(47 downto 0); 
signal tmp_exp_out  : unsigned(9 downto 0); 
signal tmp_sign_out : std_logic; 
signal tmp_next_out : std_logic;
signal tmp_out_valid : std_logic;  
begin
  Mult: FP_mult
  port map (
    clk           => clk,
    rst           => rst,
    next_in       => next_in,
    in_valid      => in_valid,    
    data_in_1  	  => data_in_1,
    data_in_2     => data_in_2,
    next_out      => tmp_next_out,
    out_valid     => tmp_out_valid,
    mant_out      => tmp_mant_out,
    exp_out       => tmp_exp_out,
    sign_out      => tmp_sign_out

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
    out_valid     => out_valid,
    data_out      => data_out

           );
end arch;