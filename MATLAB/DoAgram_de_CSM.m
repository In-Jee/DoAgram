function DoAgram_de_CSM(filename,Scan_Time_range,Scan_Freq_range,Scan_DoA_resolution,c_rng,FIG)
% DoAgram_de_CSM(filename,Scan_Time_range,Scan_Freq_range,Scan_DoA_resolution,c_rng,FIG)
% * filename: image for to load (e.g. 'test.png');
% * Scan_Time_range: decoding time range for scanning
% * Scan_Freq_range: decoding frequency range for scanning
% * Scan_angle_resolution: scanning angle resolution
%    (It should be smaller than DoA resolution in DoAgram encoding.)
% * FIG: option for drawing a figure (1 or 2)
% * c_rng: cumulation range (e.g. [10 100])
%         1 = figure
%         2 = animation w.r.t. time range
% 
% - Code description
% This is DoAgram decoding code from a DoAgram image w/ CSM method.
% Scanning time and frequency need to be setup initially.
% FIG option can draw a figure for your information.
%
% - Example1
%    f=[500:5000];
%    t=[0:0.1:4.9];
%    scan_angle=2;
%    c_rng=[10 200];
%    DoAgram_de_CSM('decoding_test.png',t,f,scan_angle,c_rng,1);
% 
% - Example2
%    f=[1900:2000];
%    t=[0:0.1:4.9];
%    scan_angle=5;
%    c_rng=[1 5];
%    DoAgram_de_CSM('decoding_test.png',t,f,scan_angle,c_rng,2);
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
disp('DoAgram-CSM')
disp('0. DoA resolution in DoAgram:')
disp(['==> ' num2str(DoA_res) ' deg '])
disp('1. Time resolution:')
disp(['==> ' num2str(dt) ' s '])
disp('2. Possible scanning time range:')
disp(['==> ' num2str(DoAgram_time(1)) ' to ' num2str(DoAgram_time(end)) ' s'])
disp('3. Frequency resolution:')
disp(['==> ' num2str(df) ' Hz '])
disp('4. Possible scanning frequency range:')
disp(['==> ' num2str(DoAgram_freq(1)) ' to ' num2str(DoAgram_freq(end)) ' Hz'])

%% Scan angle resolution setup
if DoA_res>Scan_DoA_resolution;
    disp('===============================================');
    disp('Warning: Check scan angle resolution!')
end
DoA_res=Scan_DoA_resolution;

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



%% CSM
df=df;
DoA_T=dt;
f=Scan_Freq_range;
t=Scan_Time_range;

nf_freq=round(f/df);
ntt=round(t/DoA_T)+1;

az_range=-180:DoA_res:180;
ev_range=-90:DoA_res:90;

ref_doa=zeros(length(az_range),length(ev_range));
for j=ntt  % time
    for i=nf_freq  % frequency
        ref_doa(round(dec_az(i,j)/DoA_res)+(length(az_range)-1)/2+1,round(dec_ev(i,j)/DoA_res)+(length(ev_range)-1)/2+1)=ref_doa(round(dec_az(i,j)/DoA_res)+(length(az_range)-1)/2+1,round(dec_ev(i,j)/DoA_res)+(length(ev_range)-1)/2+1)+1;
    end
end


% FIG ----------------------------
if FIG==1
    figure(5013)
        ref_doa_azi=-180:DoA_res:180;
        ref_doa_ev=-90:DoA_res:90;
        [AZI,EV]=meshgrid(ref_doa_azi,ref_doa_ev);
        surf(AZI,EV,(ref_doa)');shading interp;
        view([0 90]);
        axis equal;xlim([-180 180]);ylim([-90 90])
        caxis(c_rng);
        colormap hot
        set(gca,'xtick',[-180:30:180],'ytick',[-90:30:90])
        xlabel('Azimuth angle, deg');ylabel('Elevation angle, deg');
elseif FIG==2
    
%         for nt=0:0.1:Time_range(end)-1
          for nt=t
    
%                     t=[nt:nt+1];
                    t=nt;
%                     DoA_T=Time_resolution;
                    
                    nf_freq=round(f/df);
                    ntt=round(t/DoA_T)+1;
                    
                    az_range=-180:DoA_res:180;
                    ev_range=-90:DoA_res:90;
                    
                    ref_doa=zeros(length(az_range),length(ev_range));
                    for j=ntt  % time
                        for i=nf_freq  % frequency
                            ref_doa(round(dec_az(i,j)/DoA_res)+(length(az_range)-1)/2+1,round(dec_ev(i,j)/DoA_res)+(length(ev_range)-1)/2+1)=ref_doa(round(dec_az(i,j)/DoA_res)+(length(az_range)-1)/2+1,round(dec_ev(i,j)/DoA_res)+(length(ev_range)-1)/2+1)+1;
                        end
                    end

        figure(5013)
        ref_doa_azi=-180:DoA_res:180;
        ref_doa_ev=-90:DoA_res:90;
        [AZI,EV]=meshgrid(ref_doa_azi,ref_doa_ev);
        surf(AZI,EV,(ref_doa)');shading interp;
        view([0 90]);
        axis equal;xlim([-180 180]);ylim([-90 90])
        caxis(c_rng);
        colormap hot
        set(gca,'xtick',[-180:30:180],'ytick',[-90:30:90])
        xlabel('Azimuth angle, deg');ylabel('Elevation angle, deg');
        title(['Time=' num2str(nt) ' s'])
        pause(0.1)

        end


else

end


end
