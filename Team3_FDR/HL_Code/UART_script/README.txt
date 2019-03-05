1. input format:
	Split each of the 32-bit floating point operands into 4 8-bit numbers. Add 5 zeros at the front of the control bits and valid bit.
	For example: data_in_1 = 01000000_00010101_01001111_11011111, data_in_2 = 01000000_01000111_11011111_00111011, ctr = 00, in_valid = 1
			     input data should be: 	11011111
										01001111
										00010101
										01000000
										00111011
										11011111
										01000111
										01000000
										00000001

2. run the script:
	Connect Basys-3 board with a computer, then run the UART.py

3. output format:
	The output data in output.txt will be 4 8-bit numbers, representing data_out(7 downto 0), data_out(15 downto 8), data_out(23 downto 16), data_out(31 downto 24)
	For example: output data: 	10010011
								00100110
								11101001
								01000000
	which means data_out = 01000000_11101001_00100110_10010011