% reads multi-channel recording file to a matrix
% function [eeg] = function readmulti(fname,numchannel,chselect)
% last argument is optional (if omitted, it will read all the
% channels
%
% 20140515 takata norio: For Natsubori san LabView data
% 20150701 takata norio: bug fix. int16 -> double @ numel; transpose(eeg_ch)

function [eeg] = readmulti_DBL(fname,numchannel,chselect)

if nargin == 2
    datafile = fopen(fname,'r');
    eeg = fread(datafile,[numchannel,inf],'double');
    fclose(datafile);
    eeg = eeg';
    return
end

if nargin == 3
    % the real buffer will be buffersize * numch * (int16, 2; double, 8) bytes
    buffersize = 4096;
    
    % get file size, and calculate the number of samples per channel
    fileinfo = dir(fname);
    numel = ceil(fileinfo(1).bytes / 8 / numchannel);% 20150701: original, int16 (2 byte) -> double (8 byte).
    
    datafile = fopen(fname,'r');
    
    mmm = sprintf('%d elements',numel);
    disp(mmm);
    
    eeg=zeros(numel,length(chselect));% 20150701: row vector -> column vector
    numel=0;
    numelm=0;
    while ~feof(datafile),
        [data,count] = fread(datafile,[numchannel,buffersize],'double');
        numelm = count/numchannel;
        eeg(numel+1:numel+numelm,:) = data(chselect,:);
        numel = numel+numelm;
    end
    fclose(datafile);
end