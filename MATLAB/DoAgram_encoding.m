function [DoA_color]=DoAgram_encoding(s_az_n,s_ev_n,s_freq,time_seg,DoA_res,nbit,Alpha_data,filename,T_res,F_res,Fs)
% [DoA_color]=DoAgram_encoding(s_az_n,s_ev_n,s_freq,time_seg,DoA_res,nbit,Alpha_data,filename,T_res,F_res,Fs)
% * DoA_color: encoded DoAgram w/o alpha
% * s_az_n: Azimuth angle
% * s_ev_n: Elevation angle
% * s_freq: Frequency range
% * time_seg: Time range
% * DoA_res: DoAgram angle resolution
% * nbit: Color bit resolution (8 or 16 bit)
% * Alpha_data: Alpha data
% * filename: image file name to save (e.g. 'test.png')
% * T_res: Time resolution in s
% * F_res: Frequency resolution in Hz
% * Fs: Sampling rate in Hz
% 
% - Code description
% This is DoAgram encoding code by using a localization data in the
% preliminary process.
% The localization results for azimuth/elevation angles should be
% structured as a 2D matrix with frequency and time in the matrix columns
% and rows, respectively.
%
% - Example
%    load('Example_preliminary_localization_dataset.mat');
%    DoA_res=2;  % deg
%    T_res=0.1;  % scc
%    F_res=10;  % Hz
%    Fs=25600;  % Hz
%    nbit=8;
%    %Save to 'encodint_test.png'
%    [DoAresult]=DoAgram_encoding(s_az_n,s_ev_n,s_freq,s_time,DoA_res,nbit,Alpha_data,'encoding_test.png',T_res,F_res,Fs);
%
% -Reference: I.-J. Jung, W.-H. Cho, "A novel visual representation method
% for multi-dimensional sound scene analysis in source localization
% problem," (MSSP, 2024)
% -DOI: https://doi.org/10.1016/j.ymssp.2023.110977
% -Code: https://github.com/In-Jee/DoAgram
% # Ver.1.0.0 (30 April,2024), Code checked by MATLAB R2021a
% In-Jee Jung, Wan-Ho Cho, AUV metrology group (KRISS)
% -------------------------------------------------------------------------


s_az_n=round(s_az_n/DoA_res)*DoA_res;
s_ev_n=round(s_ev_n/DoA_res)*DoA_res;

DoA_color=[];

if nbit==8
elseif nbit==16
else
    msgbox('Error: Possible bitdepth = (8 Bit), (16 Bit)');
    return;
end


f_len=length(s_freq);
t_len=length(time_seg)-1;

ang_res=DoA_res;
% nbit;
n_col=180/ang_res+1;

if 2^nbit < n_col
msgbox(['Error: Color depth range(' num2str(2^nbit) ') < DoA range(' num2str(n_col) '). Change "nbit" or "DoA_res"' ]);
return;
end



tt=1:1:t_len;
if nbit==16
                    for dt=tt
                        for i=1:f_len
                            if s_az_n(i,dt)==0
                                i_cr=0;
                                i_cg=0;
                            elseif s_az_n(i,dt)>0
                                i_cr=0;
                                i_cg=uint16((2^nbit-1)/180*s_az_n(i,dt)); %G
                            else
                                i_cr=uint16(-(2^nbit-1)/180*s_az_n(i,dt)); %R
                                i_cg=0;
                            end

                        i_cb=uint16((2^nbit-1)/180*s_ev_n(i,dt)+(2^nbit-1)/2); %B

                        cr(i)=i_cr;
                        cg(i)=i_cg;
                        cb(i)=i_cb;
                        end
                    cr_t(:,dt)=cr';
                    cg_t(:,dt)=cg';
                    cb_t(:,dt)=cb';
                    end
elseif nbit==8
                    for dt=tt
                        for i=1:f_len
                            if s_az_n(i,dt)==0
                                i_cr=0;
                                i_cg=0;
                            elseif s_az_n(i,dt)>0
                                i_cr=0;
                                i_cg=uint8((2^nbit-1)/180*s_az_n(i,dt)); %G
                            else
                                i_cr=uint8(-(2^nbit-1)/180*s_az_n(i,dt)); %R
                                i_cg=0;
                            end

                        i_cb=uint8((2^nbit-1)/180*s_ev_n(i,dt)+(2^nbit-1)/2); %B

                        cr(i)=i_cr;
                        cg(i)=i_cg;
                        cb(i)=i_cb;
                        end
                    cr_t(:,dt)=cr';
                    cg_t(:,dt)=cg';
                    cb_t(:,dt)=cb';
                    end
end

R=(cr_t);
G=(cg_t);
B=(cb_t);


DoA_color=zeros(size(s_az_n,1),t_len,3);
DoA_color(:,:,1)=R;
DoA_color(:,:,2)=G;
DoA_color(:,:,3)=B;

if nbit==8
    DoA_color=uint8(DoA_color);
elseif nbit==16
    DoA_color=uint16(DoA_color);
else
    msgbox('Error: Possible bitdepth = (8 Bit), (16 Bit)');
    return;
end



%% Save to imagefile (Edit Metadata)
imwrite(DoA_color,filename,'Alpha',Alpha_data,'BitDepth',nbit, ...
    'Title','DoAgram','Author','IJJ','Software','MATLAB',...
    'XResolution',T_res*1000,'YResolution',F_res, 'Comment', num2str(DoA_res), 'Source', num2str(Fs), ...
    'Description',['X-axis=time[ms]; Y-axis=Frequency[Hz]; Colormap=DoA;']);


end