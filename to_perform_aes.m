% this is the code for performance evalaution with AES
% this is the code for the implementation of
% Efficient Transmission of Encrypted Images with OFDM System 
clc
clear all;
close all
addpath('support');
cd('data_images')
[J,P]=uigetfile('*.*','select the source image');
cd ..
K=imread(strcat(P,J));
K=imresize(K,[128 128]);
if size(K,3)>1
    K=rgb2gray(K);
end
%=====================
%=== encyption with AES
input_msg=char(double(K(:)));
    p=11;q=29;e=3;
    disp('Encrypted message is')
    tic;
    [ full_encrypted_msg ] = full_encryption (input_msg,p,q,e);
    toc;
    disp('Decrypted message is')
    tic;
    [ full_decrypted_msg ] =full_decryption( full_encrypted_msg,p,q,e);
    toc;
    for i=1:length(full_decrypted_msg)
        E(i)=double(full_encrypted_msg(i));
        D(i)=double(full_decrypted_msg(i));
    end
 figure,subplot(231);imshow(K,[]);title('Original Image');
 subplot(234);imhist(K);title('Original Histogram');
 EE=reshape(E,[128 128]);
 subplot(232);imshow(EE,[]);title('Encrypted Image');
 subplot(235);imhist(uint8(EE));title('Encrypted Histogram');
 DD=reshape(D ,[128 128]);
 subplot(233);imshow(DD,[]);title('Decrypted Image');
 subplot(236);imhist(uint8(DD));title('Histogram of decrypted image');
 %===============================
 % convert the encrypted message into data stream 
DB=dec2bin((E));
b=[];
for i=1:size(DB,1)
    for j=1:size(DB,2)
        b=[b strread(DB(i,j))];
    end
end

PM=pskmod(b,2);
IF=ifft(PM);
cp_len=8;
actual_cp=IF(1:cp_len+1);
data=[actual_cp IF];
%=====================
Ebno=[0:2:20];
for ii=1:length(Ebno)
r=awgn(data,Ebno(ii)-db(std2(data)));    
%=====================
RR=r(cp_len+2:end);
RF=fft(RR);
RM=pskdemod(RF,2);
[nr br(ii)]=biterr(b,RM);
 bsz=9;nb=length(RM)/bsz;
 k=1;tm=0;
 for i=1:nb
     bts=RM(k:tm+bsz);
     dc(i)=bin2dec(num2str(bts));
     k=k+bsz;
     tm=k-1;
 end
FDM =full_decryption(char(dc),p,q,e);
FD=double(FDM);
FR=reshape(FD,[128,128]);
PS(ii)=psnr(uint8(FR),uint8(K));
figure,imshow(FR,[]);title('received Image');
end

figure,semilogy(PS,br,'-x');grid on;title('PSNR Vs BER analysis');xlabel('PSNR');ylabel('BER');
figure,plot(Ebno,PS,'x-');grid on;title('PSNR Vs SNR analysis');xlabel('SNR');ylabel('PSNR');




