function LoggerPlot(s_in)

fileID = fopen(s_in);
A = fread(fileID, 'int16', 2);
fseek(fileID, 2, 'bof');
B = fread(fileID, 'int16', 2);
T = 0 : (length(A)-1);
%T = T / 360000; % hours
T = T / 100; % seconds
A = A/5;
B = B/5;
figure
subplot(3,1,1)
plot(T,A)
title('EEG')
ax1 = gca;
ax1.XLim = [0 T(length(T))];
ax1.YLim = [-1500 1500];
subplot(3,1,2)
plot(T,B)
title('EMG')
ax2 = gca;
ax2.XLim = [0 T(length(T))];
ax2.YLim = [-1500 1500];
subplot(3,1,3)
title('Spectrogram')
spectrogram(A,1024,800,1024,100);
view(90, -90);
ax3 = gca;
ax3.XLim = [0 15];
colorbar('off');
caxis([25 35]);
view(90, -90);

end