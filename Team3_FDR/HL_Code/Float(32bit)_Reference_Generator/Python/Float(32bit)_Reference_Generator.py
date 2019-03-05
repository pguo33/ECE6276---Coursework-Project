import random;

try:
    input_seq = open("input_seq.txt",'w');
    input_out_ready = open("input_out_ready.txt",'w');

    length = 32;
    counter = 0;
    Special_Case_List = ["00000000000000000000000000000000","10000000000000000000000000000000",
                         "01111111100000000000000000000000","11111111100000000000000000000000",
                         "01111111100000000000000000000001","11111111100000000000000000000001",
                         "01111111011111111111111111111111","11111111011111111111111111111111"];
    Special_Case_Counter = int(0); #Used for exausting special cases
    Test_Set_Size = 500;

    while(1):
        counter += 1 ;
        
    #Set Weighted
        Special_Case_Weighted = random.randint(0,80);
        Valid_Weighted = random.randint(0,10);
        
    #Handshake Signal
        if(counter <= (len(Special_Case_List) * len(Special_Case_List) * 2)+ 2):
            #Go through all the Special Cases at the very beginning
            #Easy for debugging
            Input_Valid ='1';
            Input_OutValid = '1';
        else:
            if(Valid_Weighted == 0):
                Input_Valid = '0';
                Input_OutValid = '0';
            elif(Valid_Weighted == 1):
                Input_Valid = '1';
                Input_OutValid = '0';
            elif(Valid_Weighted == 2):
                Input_Valid = '0';
                Input_OutValid = '1';
            else:
                Input_Valid = '1';
                Input_OutValid = '1';
                
     #Input Data               
        if(counter <= (len(Special_Case_List) * len(Special_Case_List) * 2)+ 1):
            #Go through all the Special Cases at the very beginning
            #Easy for debugging
            if(counter > 1):
                if(counter % 2 == 0):
                    #OP1
                    Input_Value = Special_Case_List[Special_Case_Counter];
                    if(counter % 16 == 0):
                        Special_Case_Counter += 1;
                else:
                    #OP2
                    Input_Value = Special_Case_List[int(((counter - 3)/2) % len(Special_Case_List))];
        else:
            if(Special_Case_Weighted == 0):
                #+0
                Input_Value = "00000000000000000000000000000000";
            elif(Special_Case_Weighted == 1):
                #-0
                Input_Value = "10000000000000000000000000000000";
            elif(Special_Case_Weighted == 2):
                #+∞
                Input_Value = "01111111100000000000000000000000";
            elif(Special_Case_Weighted == 3):
                #-∞
                Input_Value = "11111111100000000000000000000000";
            elif(Special_Case_Weighted == 4):
                #NaN(sign = 1)
                Input_Value = str(11111111100000000000000000000000 + int(bin(random.randint(0,(2 ** (length-9)) -10))[2:]));
            elif(Special_Case_Weighted == 5):
                #NaN(sign = 0)
                Input_Value = 1111111100000000000000000000000 + int(bin(random.randint(0,(2 ** (length-9)) -10))[2:]);
            elif(Special_Case_Weighted == 6):
                #MaximumNumber
                Input_Value = "01111111011111111111111111111111";
            elif(Special_Case_Weighted == 7):
                #MinimumNumber
                Input_Value = "11111111011111111111111111111111";
            else:
                Input_Value = bin(random.randint(0,(2 ** length) -1))[2:];
            
            for i in range(0,length - len(str(Input_Value))):
                Input_Value = '0' + str(Input_Value);

            
        if(counter % 2 == 0):
            #print(Input_Valid);
            #print(Input_OutValid);
            input_seq.write(Input_Valid + ',');
            input_out_ready.write(Input_OutValid + '\n');
        if(counter > 1):
            #print(Input_Value);
            if(counter % 2 == 0):
                input_seq.write(Input_Value + ',');
            else:
                input_seq.write(Input_Value + '\n');
                
    #Testset Size 100K
        if(counter == Test_Set_Size * 2):
            input_seq.write(Input_Value + '\n');
            break;
        
except:
    input_seq.close();
    input_out_ready.close();

finally:
    input_seq.close();
    input_out_ready.close();
