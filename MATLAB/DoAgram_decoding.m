function [DoAgram, DoAgram_alpha, DoAgram_Metadata, dec_azi, dec_ev]=DoAgram_decoding(filename,FIG)
% [DoAgram, DoAgram_alpha, DoAgram_Metadata, dec_azi, dec_ev]=DoAgram_decoding(filename,FIG)
% * DoAgram: decoded DoA w/o alpha
% * DoAgram_alpha: decoded DoAgram alpha
% * DoAgram_Metadata: Metadata of DoAgram
% * dec_azi: calculated azimuth angle from DoAgram
% * dec_ev: calculated elevation angle from DoAgram
% * filename: image for to load (e.g. 'test.png');
% * FIG: option for drawing a figure (1 or 2)
%         1 = azimuth, elevation angle w/o alpha
%         2 = azimuth, elevation angle w/ alpha
% 
% - Code description
% This is DoAgram decoding code from a DoAgram image.
% DoAgram, Alpha, and Metadata are basically obtained from the encoded image.
% Encoding properties can be obtained from the Metadata.
% The localization results for azimuth/elevation angles are saved as a 2D
% matrix with frequency and time in the matrix columns and rows, respectively.
% FIG option can draw a figure for your information.
%
% - Example
%    [DoAgram, alpha, Metadata, azi, ev]=DoAgram_decoding('decoding_test.png',[]);
%    DoA_res=Metadata.DoA_Resolution_deg;  % DoA resolution
%    dt=Metadata.TimeResolution_ms/1000;    % Time resolution
%    Time_range=0:dt:(dt*Metadata.TimeLine)-dt;    % DoAgram time range
%    df=Metadata.FrequencyResolution_Hz;    % Frequency resolution
%    Freq_range=0:df:(df*Metadata.FrequencyLine)-df;    % DoAgram freq. range
%    nbit=Metadata.ColorBit_per_RGB;    % Color bit resolution
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



%% FIG
if DoAgram_time==0
    disp('Cannot display the result. (-> single time taps)');
    return;
else
if FIG==1
            [TIME,FREQ]=meshgrid(DoAgram_time,DoAgram_freq);
            
            %Color: R-------------------------
            az_rng1_c=linspace(0,2^nbit-1,n_col);
            az_rng1=linspace(0,-180,n_col);
            az_rng1=round(az_rng1,1);
            %Color: G-------------------------
            az_rng2_c=linspace(0,2^nbit-1,n_col);
            az_rng2=linspace(0,180,n_col);
            az_rng2=round(az_rng2,1);
            %Color: B-------------------------
            ev_rng_c=linspace(0,2^nbit-1,n_col);
            ev_rng=linspace(-90,90,n_col);
            ev_rng=round(ev_rng,1);
            
                        
            ccc_r=flipud(az_rng1_c')/(max(max(az_rng1_c)));
            ccc_g=flipud(az_rng2_c')/(max(max(az_rng2_c)));
            ccc_b=flipud(ev_rng_c')/(max(max(ev_rng_c)));
            
            az_col1=[ccc_r zeros(length(az_rng1_c),1) zeros(length(az_rng1_c),1)];
            az_col2=[zeros(length(az_rng1_c),1) flipud(ccc_g) zeros(length(az_rng1_c),1)];
            az_col=[az_col1;az_col2];
            ev_col=[zeros(length(ev_rng_c),1) zeros(length(ev_rng_c),1) flipud(ccc_b)];
            
            
            dec_azi_cdata=DoAgram;
            dec_azi_cdata(:,:,3)=zeros(size(dec_azi_cdata(:,:,3)));            
            
            figure();clf
            c1=surf(TIME,FREQ,dec_azi);shading interp;view([0 90])
            colorbar('ticks',[-180:10:180]);caxis([-180 180])
            xlim([0 DoAgram_time(end)]);ylim([0 DoAgram_freq(end)])
            colormap(az_col)
            xlabel('Time, s');ylabel('Frequency, Hz');
            set(gca,'xtick',[0:0.5:DoAgram_time(end)],'ytick',[0:1000:DoAgram_freq(end)])
            title('Azimuth angle w/o alpha');

            
            figure();clf
            c2=surf(TIME,FREQ,dec_ev);shading interp;view([0 90]);caxis([-90 90])
            colorbar('ticks',[-90:10:90]);caxis([-90 90])
            xlim([0 DoAgram_time(end)]);ylim([0 DoAgram_freq(end)])
            colormap(ev_col)
            xlabel('Time, s');ylabel('Frequency, Hz');
            set(gca,'xtick',[0:0.5:DoAgram_time(end)],'ytick',[0:1000:DoAgram_freq(end)])
            title('Elevation angle w/o alpha');

elseif FIG==2
            [TIME,FREQ]=meshgrid(DoAgram_time,DoAgram_freq);
            
            %Color: R-------------------------
            az_rng1_c=linspace(0,2^nbit-1,n_col);
            az_rng1=linspace(0,-180,n_col);
            az_rng1=round(az_rng1,1);
            %Color: G-------------------------
            az_rng2_c=linspace(0,2^nbit-1,n_col);
            az_rng2=linspace(0,180,n_col);
            az_rng2=round(az_rng2,1);
            %Color: B-------------------------
            ev_rng_c=linspace(0,2^nbit-1,n_col);
            ev_rng=linspace(-90,90,n_col);
            ev_rng=round(ev_rng,1);
            
                        
            ccc_r=flipud(az_rng1_c')/(max(max(az_rng1_c)));
            ccc_g=flipud(az_rng2_c')/(max(max(az_rng2_c)));
            ccc_b=flipud(ev_rng_c')/(max(max(ev_rng_c)));
            
            az_col1=[ccc_r zeros(length(az_rng1_c),1) zeros(length(az_rng1_c),1)];
            az_col2=[zeros(length(az_rng1_c),1) flipud(ccc_g) zeros(length(az_rng1_c),1)];
            az_col=[az_col1;az_col2];
            ev_col=[zeros(length(ev_rng_c),1) zeros(length(ev_rng_c),1) flipud(ccc_b)];
            
            
            
            
            figure();clf
            dec_azi_cdata=DoAgram;
            dec_azi_cdata(:,:,3)=zeros(size(dec_azi_cdata(:,:,3)));
            
            im1=image(dec_azi,'AlphaData',DoAgram_alpha,'CDataMapping','scaled');view([0 -90])
            colorbar('ticks',[-180:10:180]);caxis([-180 180])
            colormap(az_col)
            a=gca;
            a.XTick=[1:round(0.5/DoAgram_time(2)):length(DoAgram_time)];
            a.XAxis.TickLabels=num2cell(DoAgram_time(a.XTick));
            a.YTick=[1:round(1000/DoAgram_freq(2)):length(DoAgram_freq)];
            a.YAxis.TickLabels=num2cell(DoAgram_freq(a.YTick));
            xlabel('Time, s');ylabel('Frequency, Hz');
            title('Azimuth angle w/ alpha');


           
            figure();clf
            im2=image(dec_ev,'AlphaData',DoAgram_alpha,'CDataMapping','scaled');view([0 -90])
            colorbar('ticks',[-90:10:90]);caxis([-90 90])
            colormap(ev_col)
            b=gca;
            b.XTick=[1:round(0.5/DoAgram_time(2)):length(DoAgram_time)];
            b.XAxis.TickLabels=num2cell(DoAgram_time(b.XTick));
            b.YTick=[1:round(1000/DoAgram_freq(2)):length(DoAgram_freq)];
            b.YAxis.TickLabels=num2cell(DoAgram_freq(b.YTick));
            xlabel('Time, s');ylabel('Frequency, Hz');
            title('Elevation angle w/ alpha');

end

end

end
