% Extract nc data to txt  (SWAT-format  met.txt)
% LINUX   从nc数据里提出经纬度点对应的所有时间序列的数据。   CMIP6数据只有365天
% 2020.11.24
close all;clear;clc

%%  input

NCfur_pt = 'I:\ClimateChangePatternData\2015-2019\ACCESS-ESM1-5\ssp585';%!!!!修改
outpt = 'I:\ClimateChangePatternData\2015-2019\ACCESS-ESM1-5\UpperYellowRiver_ACCESS-ESM1-5';%!!!!修改
xslpt='D:\ResearchSpace\DataDrivenProcessDrivenFusionFramework\data\fork.xls';%!!!!修改

% climate_model={'GFDL-ESM2M','HadGEM2-ES','IPSL-CM5A-LR','MIROC5'}; CMCC-ESM2
% scns = {'rcp26','rcp45','rcp60','rcp85'};
climate_model={'ACCESS-ESM1-5'};   %气候模式!!!!修改
%  climate_model={'CanESM5'};
% scns = {'ssp126','ssp245','ssp370','ssp585''historical',};
scns = {%!!!!修改
    %'ssp126',
    %'ssp245',
    'ssp585'
    };      %气候情景
sf=1;
NChd = 'tasmin_day';     %nc文件头名称!!!!修改
r1i1p1f1='_r1i1p1f1_gn_';      %nc文件后部分名称
% vstr = 'sfcWindAdjust';  
vstr ='tasmin';  %变量名!!!!修改
%vstr ='tasmax';  %变量名
%vstr ='tasmax';  %变量名
%vstr ='tasmax';  %变量名
% vstr ='tasmin';

start_year=2015;      %开始年份
end_year=2019;     %结束年份

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
for mdl=1:length(climate_model) %气候模式循环
    for sc = 1:length(scns)  %rcp情景循环
        for row=1:rows %坐标点循环
            lon=xls(row,1);
            lat=xls(row,2);
            disp(lon);
            disp(lat);
            row_nc=ceil((60+lat)/lat_resolution);  %求坐标位于矩阵的行列数位置
            col_nc=ceil((lon)/lon_resolution);   %仅限于经纬度大于0的地区
%             disp([row_nc,col_nc]);
            out_txtname=[outpt,filesep,NChd,'_',climate_model{mdl},'_',scns{sc},'_',num2str(row,'%03d'),'.txt'];
            fileID = fopen(out_txtname,'w');
            fprintf(fileID,'%s\r\n','20150101');
            data=[];   %初始化最终输出的矩阵
            
%             sum_year=0;
            for yr = start_year:end_year  %逐年循环
                 NC_fl = [NCfur_pt,filesep,NChd,'_',climate_model{mdl},'_',scns{sc},r1i1p1f1,num2str(yr),'.nc']; 
                 if exist(NC_fl,'file')
                        disp(yr);

        %             if exist(NC_fl,'file')
                        ndys = 365;
                        if mod(yr,400)==0||(mod(yr,4)==0 && mod(yr,100)~=0)
                            ndys = 366;
                        end
                         % ytmp = sf.*double(ncread(NC_fl,vstr,[row_nc,col_nc,1],[row_nc,col_nc,inf],[1 1 1]));  %Inf最大值

                        ytmp =sf*double(ncread(NC_fl,vstr,[col_nc,row_nc,1],[1,1,365]));  %   行列号相反，需要求逆  每年读取365个
        %                         disp(yr)
                        ytmp=squeeze(ytmp);
        %                 ytmp(ytmp==ytmp(1,1,1)) = nan;
        %                     ytmp(ytmp<0) = 0;
                        if strcmp(vstr,'pr')            %查看是否需要转换单位
                            ytmp =60*60*24*ytmp;          % kg/m2/s ---降雨 mm/day    
                        end
                        if strcmp(vstr,'tasmax')
                            ytmp =ytmp-273.15;    %k温度转摄氏度
                        end
                        if strcmp(vstr,'tasmin')
                            ytmp =ytmp-273.15;    %k温度转摄氏度
                        end
                        if strcmp(vstr,'tas')
                            ytmp =ytmp-273.15;    %k温度转摄氏度
                        end
                        data=cat(1,data,ytmp);  %将多年的数据连在在一起
                        if ndys>365     %cmip6的数据只有365天，366天采用第365天的值
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
