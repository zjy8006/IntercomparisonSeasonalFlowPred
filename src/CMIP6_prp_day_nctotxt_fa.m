% Extract nc data to txt  (SWAT-format  met.txt)
% LINUX   ��nc�����������γ�ȵ��Ӧ������ʱ�����е����ݡ�   CMIP6����ֻ��365��
% 2020.11.24
close all;clear;clc

%%  input

NCfur_pt = 'I:\ClimateChangePatternData\2015-2019\ACCESS-ESM1-5\ssp585';%!!!!�޸�
outpt = 'I:\ClimateChangePatternData\2015-2019\ACCESS-ESM1-5\UpperYellowRiver_ACCESS-ESM1-5';%!!!!�޸�
xslpt='D:\ResearchSpace\DataDrivenProcessDrivenFusionFramework\data\fork.xls';%!!!!�޸�

% climate_model={'GFDL-ESM2M','HadGEM2-ES','IPSL-CM5A-LR','MIROC5'}; CMCC-ESM2
% scns = {'rcp26','rcp45','rcp60','rcp85'};
climate_model={'ACCESS-ESM1-5'};   %����ģʽ!!!!�޸�
%  climate_model={'CanESM5'};
% scns = {'ssp126','ssp245','ssp370','ssp585''historical',};
scns = {%!!!!�޸�
    %'ssp126',
    %'ssp245',
    'ssp585'
    };      %�����龰
sf=1;
NChd = 'tasmin_day';     %nc�ļ�ͷ����!!!!�޸�
r1i1p1f1='_r1i1p1f1_gn_';      %nc�ļ��󲿷�����
% vstr = 'sfcWindAdjust';  
vstr ='tasmin';  %������!!!!�޸�
%vstr ='tasmax';  %������
%vstr ='tasmax';  %������
%vstr ='tasmax';  %������
% vstr ='tasmin';

start_year=2015;      %��ʼ���
end_year=2019;     %�������

% yrss = [2015,2100];
nrows = 600;
ncols =1440;
lats = [-60,90];
lons = [0,360];
bv = -9999;

lat_resolution=(lats(2)-lats(1))/nrows;
lon_resolution=(lons(2)-lons(1))/ncols;
%%  operate
mkdir(outpt)
Rmat =  georasterref('RasterSize',[nrows,ncols],...
    'Latlim',[lats(1) lats(2)], 'Lonlim',[lons(1) lons(2)],...
    'ColumnsStartFrom','south','RowsStartFrom','west');
% xls=xlsread(xslpt,'Sheet1','A2:B426');
xls=xlsread(xslpt,'Sheet1');
xls=xls(1:end,1:2);
rows=size(xls,1);
for mdl=1:length(climate_model) %����ģʽѭ��
    for sc = 1:length(scns)  %rcp�龰ѭ��
        for row=1:rows %�����ѭ��
            lon=xls(row,1);
            lat=xls(row,2);
            disp(lon);
            disp(lat);
            row_nc=ceil((60+lat)/lat_resolution);  %������λ�ھ����������λ��
            col_nc=ceil((lon)/lon_resolution);   %�����ھ�γ�ȴ���0�ĵ���
%             disp([row_nc,col_nc]);
            out_txtname=[outpt,filesep,NChd,'_',climate_model{mdl},'_',scns{sc},'_',num2str(row,'%03d'),'.txt'];
            fileID = fopen(out_txtname,'w');
            fprintf(fileID,'%s\r\n','20150101');
            data=[];   %��ʼ����������ľ���
            
%             sum_year=0;
            for yr = start_year:end_year  %����ѭ��
                 NC_fl = [NCfur_pt,filesep,NChd,'_',climate_model{mdl},'_',scns{sc},r1i1p1f1,num2str(yr),'.nc']; 
                 if exist(NC_fl,'file')
                        disp(yr);

        %             if exist(NC_fl,'file')
                        ndys = 365;
                        if mod(yr,400)==0||(mod(yr,4)==0 && mod(yr,100)~=0)
                            ndys = 366;
                        end
                         % ytmp = sf.*double(ncread(NC_fl,vstr,[row_nc,col_nc,1],[row_nc,col_nc,inf],[1 1 1]));  %Inf���ֵ

                        ytmp =sf*double(ncread(NC_fl,vstr,[col_nc,row_nc,1],[1,1,365]));  %   ���к��෴����Ҫ����  ÿ���ȡ365��
        %                         disp(yr)
                        ytmp=squeeze(ytmp);
        %                 ytmp(ytmp==ytmp(1,1,1)) = nan;
        %                     ytmp(ytmp<0) = 0;
                        if strcmp(vstr,'pr')            %�鿴�Ƿ���Ҫת����λ
                            ytmp =60*60*24*ytmp;          % kg/m2/s ---���� mm/day    
                        end
                        if strcmp(vstr,'tasmax')
                            ytmp =ytmp-273.15;    %k�¶�ת���϶�
                        end
                        if strcmp(vstr,'tasmin')
                            ytmp =ytmp-273.15;    %k�¶�ת���϶�
                        end
                        if strcmp(vstr,'tas')
                            ytmp =ytmp-273.15;    %k�¶�ת���϶�
                        end
                        data=cat(1,data,ytmp);  %�����������������һ��
                        if ndys>365     %cmip6������ֻ��365�죬366����õ�365���ֵ
                           data=cat(1,data,data(end)); 
                        end
%                         sum_year=sum_year+1;
                 end
            end
            
            disp([NC_fl,'  ok'])
%             disp(data);
            fprintf(fileID,'%3.2f\r\n',round(data,2));
            fclose(fileID);
            disp([out_txtname,'  ok']);
            clearvars ytmp data
        end
    end
end
disp('Finish!')
