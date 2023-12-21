function [A, B] = LoggerRead(s_in)

fileID = fopen(s_in);
A = fread(fileID, 'int16', 2);
fseek(fileID, 2, 'bof');
B = fread(fileID, 'int16', 2);

end
