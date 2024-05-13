function DoAgram_refmap(nbit,ang_res)
% DoAgram_refmap(nbit,ang_res)
% - nbit: number of color bit (here, 8 or 16 bit only)
% - ang_res: angle resolution (deg)
% 
% - Code description
% An example for DoAgram reference map for human interpretation.
% The color resolution should be higher than angle resolution
% 
% - Example
%    DoAgram_refmap(8,1)
%
% -Reference: I.-J. Jung, W.-H. Cho, "A novel visual representation method
% for multi-dimensional sound scene analysis in source localization
% problem," (MSSP, 2024)
% -DOI: https://doi.org/10.1016/j.ymssp.2023.110977
% -Code: https://github.com/In-Jee/DoAgram
% # Ver.1.0.0 (30 April,2024), Code checked by MATLAB R2021a
% In-Jee Jung, Wan-Ho Cho, AUV metrology group (KRISS)
% -------------------------------------------------------------------------


%% Basic
n_col=180/ang_res+1;

if 2^nbit < n_col
msgbox('Error: color resolution < angle resolution')
return;
end

%% Color setup for Refmap visualiation
%Color: R-------------------------
az_rng1_c=linspace(0,2^nbit-1,n_col);
az_rng1_c=round(az_rng1_c);
az_rng1=linspace(0,-180,n_col);
az_rng1=round(az_rng1,1);

%Color: G-------------------------
az_rng2_c=linspace(0,2^nbit-1,n_col);
az_rng2_c=round(az_rng2_c);
az_rng2=linspace(0,180,n_col);
az_rng2=round(az_rng2,1);

%Color: B-------------------------
ev_rng_c=linspace(0,2^nbit-1,n_col);
ev_rng_c=round(ev_rng_c);
ev_rng=linspace(-90,90,n_col);
ev_rng=round(ev_rng,1);


%% Angle range setup for Refmap visualiation
azi=[az_rng1 az_rng2];
ev=ev_rng;


%% Reference map visualization
figure()
azi2=[fliplr(az_rng1) az_rng2];
ev2=ev_rng;
[AZI2 EV2]=meshgrid(azi2,ev2);
C2(:,:,1)=ones(n_col,n_col*2).*[fliplr(az_rng1_c) zeros(1,n_col)];
C2(:,:,2)=ones(n_col,n_col*2).*[zeros(1,n_col) az_rng2_c];
C2(:,:,3)=repmat(ev_rng_c',1,n_col*2);

if nbit==8
    C2=uint8(C2);
else if nbit==16
        C2=uint16(C2);
    end
end

image(-180:ang_res:180,fliplr(ev),flipud(C2), 'CDataMapping', 'direct')
xlabel('Azimuth angle, deg');
ylabel('Elevation angle, deg');
axis equal
xlim([-180 180]);ylim([-90 90])
view([0 -90])

end