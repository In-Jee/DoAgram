% --------------------
% DoAgram Test code
% --------------------
% 
% * ---Functions---*
%   1) DoAgram_refmap.m
%       : Draw a reference DoAgram colormap.
%   2) DoAgram_encoding.m
%       : DoAgram encoding for a image file.
%   3) DoAgram_decoding.m
%       : Decoding DoA data from a DoAgram image file.
%   4) DoAgram_de_Tscan.m
%       : Decoding DoAgram by using the T-scan method.
%   5) DoAgram_de_Fscan.m
%       : Decoding DoAgram by using the F-scan method.
%   6) DoAgram_de_TFscan.m
%       : Decoding DoAgram by using the TF-scan method.
%   7) DoAgram_de_CSM.m
%       : Decoding DoAgram by using the CSM method.
% 
% 
%   -Reference: I.-J. Jung, W.-H. Cho, "A novel visual representation method
%   for multi-dimensional sound scene analysis in source localization
%   problem," (MSSP, 2024)
%   -DOI: https://doi.org/10.1016/j.ymssp.2023.110977
%   -Code: https://github.com/In-Jee/DoAgram
%   # Ver.1.0.0 (30 April,2024), Code checked by MATLAB R2021a
%   In-Jee Jung, Wan-Ho Cho, AUV metrology group (KRISS)


%% Main
clear all;clc;

% 1. DoAgram reference color map  ----------------------------------------
nbit=8;
angle_resolution=10;
DoAgram_refmap(nbit,angle_resolution)

clear all;clc;


% 2. DoAgram encoding test  ---------------------------------------------
% (Information of the localization data, 'Example_preliminary_localization_dataset.mat')
%   *Algorithm: 3D sound intensimetry
%   *Microphone: Tetrahedron array w/ 4 microphone (d=30 mm of mic.spacing)
%   *Source signals: 5 (Fig.4 in the reference paper (I.-J.Jung et al.MSSP,2024)
%   *Time length=5 s
%   *Sampling rate=25.6 kHz
%   *Alphadata=average coherence
%   *Time resolution=0.1 s
%   *Frequency resolution=10 Hz
%   *Color bit=8 bit (RGB)
clear all;clc;
load('Example_preliminary_localization_dataset.mat');
DoA_res=2;  % DoA angle resolution of the localization method, deg
T_res=0.1;  % Time resolution, s
F_res=10;  % Frequency resolution, Hz
Fs=25600;  % sampling rate, Hz
nbit=8;
DoAgram_encoding(s_az_n,s_ev_n,s_freq,s_time,DoA_res,nbit,Alpha_data,'test.png',T_res,F_res,Fs); %Save to 'encodint_test.png'
 

% 3-1. DoAgram decoding test1  --------------------------------------------
clear all;clc;
[DoAgram, alpha, Metadata, azi, ev]=DoAgram_decoding('test.png',2);
DoAgram_refmap(8,2); % By using the refmap, you can find source DoA heuristically.
Metadata % Encoding information can be found by using the Metadata.
 

% 3-2. DoAgram decoding test2  --------------------------------------------
% a) T-scan examples
   clear all;clc;
   f=[500 1950 3500]; t=[0:0.1:4.9]; alpha_thres=0.2;
   DoAgram_de_Tscan('test.png',t,f,alpha_thres,1);  % figure
   DoAgram_de_Tscan('test.png',t,f,alpha_thres,2);  % animation
% b) F-scan examples
   clear all;clc;
   f=[[4280:10:4640] [5050:10:5530] [5920:10:6230]]; t=[2.0 2.9]; alpha_thres=0.2;
   DoAgram_de_Fscan('test.png',t,f,alpha_thres,1);  % figure
   DoAgram_de_Fscan('test.png',t,f,alpha_thres,2);  % animation
% c) TF-scan examples
   clear all;clc;
   t=[0:0.1:4.9]; f=t*4000/5; alpha_thres=0.2;
   DoAgram_de_TFscan('test.png',t,f,alpha_thres,1);  % figure
   DoAgram_de_TFscan('test.png',t,f,alpha_thres,2);  % animation
% d) CSM examples
   clear all;clc;
   f=[500:5000]; t=[0:0.1:4.9]; scan_angle=2; c_rng=[10 200];
      DoAgram_de_CSM('test.png',t,f,scan_angle,c_rng,1);  % figure
   f=[1900:2000]; t=[0:0.1:4.9]; scan_angle=5; c_rng=[1 5];
      DoAgram_de_CSM('test.png',t,f,scan_angle,c_rng,2);  % animation