function [re_dec_azi re_dec_ev re_time re_freq]=DoAgram_de_Tscan(filename,Scan_Time_range,Scan_Freq_range,Alpha_threshold,FIG)
% [re_dec_azi re_dec_ev re_time re_freq]=DoAgram_de_Tscan(filename,Scan_Time_range,Scan_Freq_range,Alpha_threshold,FIG)
% * re_dec_azi: scanned azimuth angle
% * re_dec_ev: scanned elevation angle
% * re_time: scanned time range
% * re_freq: scanned frequency range
% * filename: image for to load (e.g. 'test.png');
% * Scan_Time_range: decoding time range for scanning
% * Scan_Freq_range: decoding frequency range for scanning
% * Alpha_threshold: threshold to decoding
% * FIG: option for drawing a figure (1 or 2)
%         1 = figure
%         2 = animation w.r.t. time range
% 
% - Code description
% This is DoAgram decoding code from a DoAgram image w/ T-scan method.
% Scanning time,frequency and alpha threshold need to be setup initially.
% Scanned azimuth and elevation angle can be obtained.
% FIG option can draw a figure for your information.
% Colorbar indicates the scan frequency range.
%
% - Example1
%    f=[500 1950 3500];
%    t=[0:0.1:4.9];
%    alpha_thres=0.2;
%    DoAgram_de_Tscan('decoding_test.png',t,f,alpha_thres,1);
% 
% - Example2
%    f=[1950];
%    t=[0:0.1:4.9];
%    alpha_thres=0.2;
%    DoAgram_de_Tscan('decoding_test.png',t,f,alpha_thres,2);
%
% -Reference: I.-J. Jung, W.-H. Cho, "A novel visual representation method
% for multi-dimensional sound scene analysis in source localization
% problem," (MSSP, 2024)
% -DOI: https://doi.org/10.1016/j.ymssp.2023.110977
% -Code: https://github.com/In-Jee/DoAgram
% # Ver.1.0.0 (30 April,2024), Code checked by MATLAB R2021a
% In-Jee Jung, Wan-Ho Cho, AUV metrology group (KRISS)
% -------------------------------------------------------------------------








%%
[DoAgram dummycolumn DoAgram_alpha]=imread(filename);

DoAgram_alpha=double(DoAgram_alpha)./max(double(DoAgram_alpha));
DoAgram_info=imfinfo(filename);
dt=DoAgram_info.XResolution/1000;
df=DoAgram_info.YResolution;
Time_range=DoAgram_info.Width;
Freq_range=DoAgram_info.Height;
DoA_res=str2num(DoAgram_info.Comment);
nbit=(DoAgram_info.BitDepth)/3;

DoAgram_freq=0:df:(df*Freq_range)-df;
DoAgram_time=0:dt:(dt*Time_range)-dt;

DoAgram_Metadata=struct('Filename',DoAgram_info.Filename, ...
        'Filesize_KB',(DoAgram_info.FileSize)/1000, ...
        'Foramt',DoAgram_info.Format, ...
        'TimeLine',DoAgram_info.Width, ...
        'TimeResolution_ms',DoAgram_info.XResolution, ...
        'FrequencyLine',DoAgram_info.Height, ...
        'FrequencyResolution_Hz',DoAgram_info.YResolution, ...
        'Axis',DoAgram_info.Description,...
        'Source_SamplingRate_Hz', str2num(DoAgram_info.Source), ...
        'DoA_Resolution_deg',str2num(DoAgram_info.Comment), ...
        'ColorBit',DoAgram_info.BitDepth, ...
        'ColorBit_per_RGB',(DoAgram_info.BitDepth)/3, ...
        'Title',DoAgram_info.Title, ...
        'Author',DoAgram_info.Author, ...
        'Copyright',DoAgram_info.Copyright, ...
        'Software',DoAgram_info.Software);


DoA_res=DoAgram_Metadata.DoA_Resolution_deg;
nbit=DoAgram_Metadata.ColorBit_per_RGB;

%%

disp(' ');disp(' ');disp(' ');
disp('DoAgram-Tscan')
disp('1. Time resolution:')
disp(['==> ' num2str(dt) ' s '])
disp('2. Possible scanning time range:')
disp(['==> ' num2str(DoAgram_time(1)) ' to ' num2str(DoAgram_time(end)) ' s'])
disp('3. Frequency resolution:')
disp(['==> ' num2str(df) ' Hz '])
disp('4. Possible scanning frequency range:')
disp(['==> ' num2str(DoAgram_freq(1)) ' to ' num2str(DoAgram_freq(end)) ' Hz'])

%%
if nbit==8
elseif nbit==16
else
    msgbox('Error: Possible bitdepth = (8 Bit), (16 Bit)');
    return;
end

ang_res=DoA_res;
n_col=180/ang_res+1;


dec_azi1_c=(DoAgram(:,:,1));
dec_azi2_c=(DoAgram(:,:,2));
dec_ev_c=(DoAgram(:,:,3));

%encoding ex
dec_azi1=((double(dec_azi1_c))*-180/(2^nbit-1)); %dec-R
dec_azi2=((double(dec_azi2_c))*180/(2^nbit-1)); %dec-R
dec_azi=dec_azi1+dec_azi2;
dec_ev=((double(dec_ev_c)-(2^nbit-1)/2)*180/(2^nbit-1)); %dec-R

% Applying resolution
dec_azi=round(dec_azi/DoA_res)*DoA_res;
dec_ev=round(dec_ev/DoA_res)*DoA_res;
dec_az=dec_azi;



%% Tscan
df=df;
DoA_T=dt;

% Frequency
f=Scan_Freq_range;
nf_freq=round(f/df);
f_freq=DoAgram_freq(nf_freq+1);
f_len=length(f_freq);

% Time
t=Scan_Time_range;
ntt=round(t/DoA_T)+1;
tt=DoAgram_time(ntt);
t_len=length(tt);

% Filtering
clear re_dec_azi re_dec_ev re_alpha_data
re_dec_azi=reshape(dec_az(nf_freq,ntt),f_len*t_len,1);
re_dec_ev=reshape(dec_ev(nf_freq,ntt),f_len*t_len,1);
re_alpha_data=reshape(DoAgram_alpha(nf_freq,ntt),f_len*t_len,1);

re_dec_azi(find(re_alpha_data<Alpha_threshold))=NaN;
re_dec_ev(find(re_alpha_data<Alpha_threshold))=NaN;
ttext=num2str(reshape(repmat((f_freq),t_len,1),f_len*t_len,1));


% FIG2 = Animation -----------------------------------------------------
if FIG==2
figure()
col=jet(f_len);
for i=ntt
scatter3(dec_az(nf_freq,i),dec_ev(nf_freq,i),f_freq,DoAgram_alpha(nf_freq,i)*100+1,col,'fill')
if i==1
    colormap(jet(f_len))
end
      colormap(jet(length(f)))
      colorbar('ticks',[1:length(f)],'TickLabels',num2cell(f_freq))
      axis equal;xlim([-180 180]);ylim([-90 90]);box on;view([0 90]);

if f_freq(end)-f_freq(1)>0
      caxis([1-0.5 length(f)+0.5])
end
set(gca,'xtick',[-180:30:180],'ytick',[-90:30:90])
xlabel('Azimuth angle, deg');ylabel('Elevation angle, deg');
title(['Time index=' num2str(t(i)) ' s'])
pause(0.01)
end
% ----------------------------------------------------------------------

% FIG1  -----------------------------------------------------
elseif FIG==1
figure()
col=jet(f_len);
scatter3(re_dec_azi,re_dec_ev,repmat(f_freq,1,t_len),re_alpha_data*100+1,repmat(col,t_len,1),'fill')
for i=1:f_len
text(re_dec_azi(i:f_len:end),re_dec_ev(i:f_len:end),repmat(f_freq(i),1,t_len),num2str(tt'),'fontsize',9,'color',col(i,:)*0.6)
end
axis equal;xlim([-180 180]);ylim([-90 90]);box on;view([0 90]);
caxis([1-0.5 length(f)+0.5])
colormap(jet(length(f)))
colorbar('ticks',[1:length(f)],'TickLabels',num2cell(f_freq))
set(gca,'xtick',[-180:30:180],'ytick',[-90:30:90])
xlabel('Azimuth angle, deg');ylabel('Elevation angle, deg');
% ----------------------------------------------------------------------

else
end

re_time=tt';
re_freq=str2num(ttext);


end
