
--Engineer     : Dingxin Jin
--Date         : 11/05/2018
--Name of file : tb_Wrapper.vhd
--Description  : Testbench for Wrapper
--Template     : Lab assignments' testbench written by Yanshen Su

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use std.env.all;
use std.textio.all;
use ieee.std_logic_textio.all;
library floatfixlib;
use floatfixlib.fixed_float_types.all;
use floatfixlib.fixed_pkg.all;
use floatfixlib.float_pkg.all;

entity tb_Mult_Wrapper is
  generic (
    input_file_str  : string := "input_seq.txt";
    output_file_str : string := "output.txt"
          );
end tb_Mult_Wrapper;

architecture tb_arch of tb_Mult_Wrapper is 
  component Mult_Wrapper 
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
  --signals local only to the present ip
  signal clk, rst      : std_logic;
  signal next_out      : std_logic;
  signal in_valid      : std_logic  := '0';
  signal data_in_1     : std_logic_vector(31 downto 0);
  signal data_in_2     : std_logic_vector(31 downto 0);
  signal next_in       : std_logic;
  signal out_valid     : std_logic;
  signal data_out      : std_logic_vector(31 downto 0); 
  --signals related to the file operations
  file   input_data_file  : text;
  file   input_ready_file : text;
  file   output_file      : text;
  -- time
  constant T: time  := 20 ns;
  signal cycle_count: integer;
  signal hanged_count: integer;
begin
  DUT: Mult_Wrapper 
  port map (
    clk           => clk,
    rst           => rst,
    next_in       => next_in,
    in_valid      => in_valid,    
    data_in_1  	  => data_in_1,
    data_in_2     => data_in_2,
    next_out      => next_out,
    out_valid     => out_valid,
    data_out      => data_out

           );

  p_clk: process
  begin
    clk <= '0';
    wait for T/2;
    clk <= '1';
    wait for T/2;
  end process;

  -- counting cycles
  p_cycle: process (clk)
  begin
    if (rising_edge(clk)) then
      if (rst = '1') then
        cycle_count <= 0;
      else 
        cycle_count <= cycle_count + 1;
      end if;
    end if;
  end process;

  -- counting hang cycles
  p_hang_cycle: process (clk)
  begin
    if (rising_edge(clk)) then
      if (rst = '1' or out_valid = '1') then
        hanged_count <= 0;
      else 
        hanged_count <= hanged_count + 1;
      end if;
    end if;
  end process;


  -- SIMULATION STARTS
  p_read_data: process
    variable input_data_line  : line;
    variable term_in_valid    : std_logic;
    variable term_data_in_1   : std_logic_vector (31 downto 0);
    variable term_data_in_2   : std_logic_vector (31 downto 0);
    variable char_comma       : character;
    variable output_line      : line;
  begin
    file_open(input_data_file, input_file_str, read_mode);
    file_open(output_file, output_file_str, write_mode);
    -- write the header
    write(output_line, string'("cycle"), left, 14);
    write(output_line, string'("out_valid"), left, 14);
    write(output_line, string'("next_out"), left, 20);
    write(output_line, string'("data_out"), right, 33);
    write(output_line, string'("  "));
    writeline(output_file, output_line);

    rst <= '1';
    wait until rising_edge(clk);
    rst <= '1';
    wait until rising_edge(clk);
    rst <= '0';

    -- read first line: coefs, and discard
    readline(input_data_file, input_data_line);
    while not endfile(input_data_file) loop
      -- read from input 
      readline(input_data_file, input_data_line);
      read(input_data_line, term_in_valid);
      read(input_data_line, char_comma);
      read(input_data_line, term_data_in_1);
      read(input_data_line, char_comma);
      read(input_data_line, term_data_in_2);
      if (in_valid = '0') then
        -- drive the DUT
        in_valid  <= term_in_valid;
        data_in_1 <= term_data_in_1;
        data_in_2 <= term_data_in_2;
      else
        while (next_in /= '1') loop
          wait until rising_edge(clk);
        end loop;
        -- drive the DUT
        in_valid  <= term_in_valid;
        data_in_1 <= term_data_in_1;
        data_in_2 <= term_data_in_2;
      end if;
      wait until rising_edge(clk);
    end loop;
    -- end generating input ...
    if (in_valid = '1') then 
      while (next_in /= '1') loop 
        wait until rising_edge(clk);
      end loop; 
    end if;
    in_valid <= '0';
    wait;
  end process;


  p_read_ready: process
    variable input_ready_line : line;
    variable term_next_out    : std_logic;
  begin
    file_open(input_ready_file, "input_out_ready.txt", read_mode);
    while not endfile(input_ready_file) loop
      wait until rising_edge(clk);
      -- read from input 
      readline(input_ready_file, input_ready_line);
      read(input_ready_line, term_next_out);
      next_out <= term_next_out;
    end loop;
    wait until rising_edge(clk);
    if (next_out = '0') then
      next_out <= '1';
    end if;
    wait;
  end process;


  -- sampling the output
  p_sample: process (clk)
    variable output_line      : line;
  begin
    if (rising_edge(clk)) then
      if (rst = '0') then
        -- sample and write to output file
        write(output_line, cycle_count, left, 20);
        write(output_line, out_valid, left, 20);
        write(output_line, next_out, left, 20);
        if (out_valid = '1' and next_out = '1') then
          write(output_line, data_out(31));
          write(output_line, string'(":"));
          write(output_line, data_out(30 downto 23));
          write(output_line, string'(":"));
          write(output_line, data_out(22 downto 0));
          write(output_line, string'("  "));
        else
          write(output_line, string'("----"), right, 31);
          write(output_line, string'("  "));
        end if;
        writeline(output_file, output_line);
      end if;
    end if;
  end process;

  -- end simulation
  p_endsim: process (clk) 
  begin
    if (rising_edge(clk)) then 
      if (hanged_count >= 500) then 
   	file_close(input_data_file);
  	file_close(input_ready_file);
  	file_close(output_file);
        report "Test completed";
        stop(0);
      end if; 
    end if;
  end process;



end tb_arch;

