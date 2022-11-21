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
% channel
Ebno=50;
r=awgn(data,Ebno-db(std2(data)));    
%=====================
% at the receiver
RR=r(cp_len+2:end);
RF=fft(RR);
RM=pskdemod(RF,2);
[nr br]=biterr(b,RM);
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
figure,imshow(FR,[]);title('received Image with AES-OFDM');
%===============================================
%====== Perform DES ====================
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
actual_cp=DIF(1:cp_len+1);
Ddata=[actual_cp DIF];
%=====================
Ebno=30;
rD=awgn(Ddata,Ebno-db(std2(Ddata)));    
%=====================
RRD=rD(cp_len+2:end);
RFD=fft(RRD);
RMD=pskdemod(RFD,2);
[nrd brd]=biterr(En,RMD);
blk=64;nb=size(RMD,2)/blk;
 k=1;tm=0;
 for i=1:nb
     cip=RMD(k:tm+blk);
     plaintext=SF_Decryption(cip,K1,K2,K3,K4,K5);
     decrypt_msg(:,i)=Binary2Dec(plaintext);
     k=k+blk;
     tm=k-1;
 end
 Rimg=reshape(decrypt_msg,[128 128]);
 figure,imshow(Rimg,[]);title ('with DES -OFDM');






