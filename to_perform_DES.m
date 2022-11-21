% this is the code for evaluating performance with DES-OFDM
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
[Data,padding]=Scalling(K,8);
Data_binary=convert2bin(Data);

% Key Selection and Expansion
% Input the key in the form of 133457799bbcdff1
hex_key = '133457799bbcdff1';
[bin_key] = Hex2Bin( hex_key );
[K1,K2,K3,K4,K5]=SF_Key_Gen(bin_key);

% Encryption and Decryption
orignal_msg=[];
  encrypt_msg=[];
  decrypt_msg=[];
  En=[];
for i=1:size(Data_binary,1)
    orignal=Data_binary(i,:);
    tic
    [cipher]=SF_Encrypt(orignal,K1,K2,K3,K4,K5);
    En=[En double(cipher)];
end
DPM=pskmod(En,2);
DIF=ifft(DPM);
cp_len=8;
actual_cp=DIF(1:cp_len+1);
Ddata=[actual_cp DIF];
%=====================
Ebno=[0:2:20];
for ii=1:length(Ebno)
rD=awgn(Ddata,Ebno(ii)-db(std2(Ddata)));    
%=====================
RRD=rD(cp_len+2:end);
RFD=fft(RRD);
RMD=pskdemod(RFD,2);
[nrd brd(ii)]=biterr(En,RMD);
blk=64;nb=size(RMD,2)/blk; k=1;
 k=1;tm=0;
 for i=1:nb
     cip=RMD(k:tm+blk);
     plaintext=SF_Decryption(cip,K1,K2,K3,K4,K5);
     decrypt_msg(:,i)=Binary2Dec(plaintext);
     k=k+blk;
     tm=k-1;
 end
 Rimg=reshape(decrypt_msg,[128 128]);
 PS(ii)=psnr(uint8(Rimg),uint8(K));
 figure,imshow(Rimg,[]);title ('with DES -OFDM');
end
figure,semilogy(PS,brd,'-x');grid on;title('PSNR Vs BER analysis');xlabel('PSNR');ylabel('BER');
figure,plot(Ebno,PS,'x-');grid on;title('PSNR Vs SNR analysis');xlabel('SNR');ylabel('PSNR');





