function [X] = mydft(x)
%離散フーリエ変換 [X] = mydft(x)
%入力信号 x = 信号
%出力引数 X = x の離散フーリエ変換
N = length (x);
j = i
kn = 0:N-1;
WN = exp(-j*2*pi/N);
WNkn = WN.^kn;
X = zeros(1,N);
for k = 0:N-1
    for n = 0:N-1
        p = mod(k*n,N);
        X(k+1) = X(k+1) + x(n+1)*WNkn(p+1);
    end
end