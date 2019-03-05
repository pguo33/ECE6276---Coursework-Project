Steps:
(1) Enter "Python" directory.

(2) Double click "Float(32bit)_Reference_Generator.exe" to generate "input_seq.txt" and "input_out_ready.txt".

(3) Move the two generated "*.txt" files to your ModelSim work directory.

(4) Use VHDL source file in "VHDL" directory. Change the equation in "Reference_Generator.vhd"(line 60) to generate reference files of different operands. Also, Change the Stages_Num constant(line 38) to simulate pipelines with different number of stages.

(5) Simulate source file with testbench file in "VHDL" directory to generate "output_ref.txt". These steps are similar to our Lab assignments.

(6) The beginning 64 test vectors of "input_seq.txt" are purposefully set to cover all the exception situation in floating point arithmetic, and all of these 64 test vectors are valid. You can take advantage of this feature to debug your codes.