%Matlab�t�@�C������f�[�^��ǂ݁Afilter���āA�X�p�C�N��臒l�Ŕ��ʂ��A�X�p�C�N�̕p�x��PTSH���v���b�g����
%�S�`���l��16ch�ŉ�͂���B

clear all

%% load data
cd G:\KEIO\Electphysiol\D1ChR2\20210201_test_in_saline\rec-3 %�f�[�^(matlab file, TDTd.mat)������t�@���_�[
data=load('TDTd');
data1=data.rawD;
ch=16; %number of channel
SR=data.fs; %sampling rate

%% viewer

Length=length(data1); %data size
ttt=(1:Length)./SR; % time vector in sec
for i=1:ch
     data_plot(:,i)=data1(:,i)+1000*(16-i);
end

% figure(1); plot(ttt,data_plot);
% xlabel('Time (s)')
% ylabel('Amplitude')

%% stimu�̃^�C�~���O
Stimu=data.epocs.stim.onset.*SR; %���l��frame��
%Stimu=180*SR;

%% �O�����@�o���h�p�X800-3k
bpFilt1 = designfilt('bandpassiir','HalfPowerFrequency1',600, ...
         'HalfPowerFrequency2',6000,'FilterOrder',20,'SampleRate',SR);
     %�o���h�X�p�XIIR �t�B���^�[
     % 800 -3000 Hz �ł��� 20 ���̃o���h�p�X IIR �t�B���^�[��݌v���܂��B
     %�T���v�����[�g�� 24414 Hz �ł��B�t�B���^�[�̎��g���������������܂��B

for i=1:ch 
    d=double(data1(:,i));
    data2=filtfilt(bpFilt1,d);
    Data_filter(:,i)=data2;
 end


%plot data
% figure(2);
% setFig([],[],[],[],['band_path_600_3000']);hold on;
% plot(ttt,Data_filter(:,2)); 

%% �X�p�C�N�̒��o

[v,t]=size(Data_filter); % v�̓f�[�^�̒����At��channel��

for i=1:t
    
    S=Data_filter(:,i);
    thr=4*(median(abs(S(:)/0.6745))); %threshold 3*median, median is absolute value of the filtered LFP/0.6745
                                      %�󋵂ɂ����thr��ς��Ă���B�g�c�_���ł��Ⴄ
                                      %3*median (NatComm)
                                      %5*median (NatNeurosci)
                                      %4*median (CellRep)
    S1=-S;
    %S2=S1>0;
    %S3=S1(S2); 
    [pks,locs] = findpeaks(S1,'MinPeakHeight',thr,'MinPeakDistance',49);
      %peak��������Bthr�ȏ�̃s�[�N�������A49�ȏ�̃s�[�N����������
      %�G���[�������ł��Ȃ��u���͈������������܂��B�v��2018b��findpeaks��2019b��findpeaks�͈Ⴄ�������B2019b�Ő�������
      
    X{i,:}=locs; %�s�[�N������x���̒l �� ���̃f�[�^�����̂܂܃��X�^�[�v���b�g�ɂȂ�B
    Data_ch(:,i)=S; %������channel�̎��n��f�[�^
    thr_ch(:,i)=thr; %������channel��臒l
          
 end
       
% 12ch���Ŕg�`��臒l��plot
figure(3);
for i=1:ch
    label=strcat('ch',num2str(i));
    ax.sp1=subplot(4,4,i);setFig([],[],[],[],[label]);hold on;
    h.p1=plot(Data_ch(:,i)); 
    h.p2=plot([1 length(Data_ch(:,i))],[-thr_ch(:,i) -thr_ch(:,i)],'r');
    h.p3=plot([Stimu Stimu],[-200 200],'r');
    ylim([-100 100])
end


%% ��͂���Ch�ŃX�p�C�N�̎��o��


for i=1:t
    data3=Data_ch(:,i);
    time=X{i,1};
    
    z=length(time);
    L=length(data3);
    
    for n=2:z
        time2=time(n,1);
        t1=time2-12;
        t2=time2+35;
        
        if t1<0
           Spike=data3(1:48,:);
        elseif t2>L
           Spike=data3(L-48:L,:);
        else
           Spike=data3(t1:t2,:);
        end
    
        Waveform(:,n)=Spike;
      
    end
    
    Waveform2{i,1}=Waveform;
    clear Waveform;
    
end

% A=Waveform2{13,1};
% A_pre=A(:,1:6000);
% A_stimu=A(:,6001:10000);
% A_post=A(:,10001:17000);
% Ave_A_pre=mean(A_pre,2);
% Ave_A_stimu=mean(A_stimu,2);
% Ave_A_post=mean(A_post,2);

%% average waveform���o���B

for i=1:t
    Waveform=Waveform2{i,1};
    Waveform_ave(:,i)=mean(Waveform,2);
    Waveform_std(:,i)=std(Waveform',1)';

end

%x��
x_axis=(-12:35)./SR.*1000; %scale=ms,   t1=time2-12,  t2=time2+35;

% 12ch����spike�̔g�`��plot
figure(4);
for i=1:ch
     label=strcat('ch',num2str(i));
     ax.sp1=subplot(4,4,i);setFig([],['time(ms)'],['uV'],[],[label]);hold on;
     h.p1=errorbar(x_axis,Waveform_ave(:,i),Waveform_std(:,i));
end


%% PSTH���o���BX���g��

[Length,N_Ch]=size(Data_filter);
RasterPlot=zeros(Length,N_Ch);

for i=1:N_Ch
    X3=X{i,1};
    L=length(X3);
    
    for n=1:L
        RasterPlot(X3(n,1),i)=1;
    end
end

RecoTime=Length/SR; %�f�[�^�����̎���(sec)
MaxRecoTime=round(RecoTime)-1;
bin_duration=1; %bin�̒���(sec)
bin=SR/bin_duration; %bin (sec)
Num_bin=MaxRecoTime/bin_duration;

PSTH=zeros(Num_bin,N_Ch);

for i=1:N_Ch
    for n=1:Num_bin
        a=RasterPlot(bin*(n-1)+1:bin*n,i);
        b=sum(a);
        PSTH(n,i)=b;
        
    end
end


% 12ch����PSTH��plot, �u����plot
figure(5);
for i=1:ch
     max_PSTH=max(PSTH(:,i));
     label=strcat('ch',num2str(i));
     ax.sp1=subplot(4,4,i);setFig([],['time(sec)'],['spike count/s'],[],[label]);hold on;
     h.p1=bar(PSTH(:,i));
     h.p2=plot([round(Stimu/SR) round(Stimu/SR)],[0 40],'r');
     ylim([0 max_PSTH]);
end


















