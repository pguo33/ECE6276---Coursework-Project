import serial

fin=open("input.txt")
while True:
   in_lines=fin.readlines()
   if not in_lines:
       break
   list_in = []
   for in_line in in_lines:
       list_in.append(in_line.strip('\n'))
fin.close()

ser=serial.Serial("com4",9600,timeout=5)
for i in list_in:
   send_b = chr(int(i,2)).encode("Latin-1")
   print(i)   
##   print(send_b)
   ser.write(send_b)

print('\n')

fout=open("output.txt","w")
data = ser.readline().decode("Latin-1")
##print(data)
for i in range(len(data)):
   recv_b = "%08d" % int(bin(ord(data[i])).replace('0b', ''))
   print(recv_b)
   fout.write(recv_b)
   fout.write('\n')
fout.close()
