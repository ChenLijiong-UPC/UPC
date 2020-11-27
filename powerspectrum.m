%-------------------------------------------------------------------------------------%
% Powerspectrum:Calculate the power spectrum;
% Update:2020/10/16;
% Author:Chenlj;
%-------------------------------------------------------------------------------------%


%% 选取数据文件路径，读取子路径文件，选取目标数据段

clear all;

filepath = uigetdir('*.*','请选择文件夹');
% userpath(filepath);

maindir = filepath;

subdir  = dir( maindir );

for i = 1:length(subdir)
    if( isequal(subdir(i).name, '.')||...
        isequal(subdir(i).name, '..')||...
        ~subdir(i).isdir)
        continue;
    end
    subdirpath = fullfile(maindir,subdir(i).name,'*Z.sac' );
    dat = dir(subdirpath)              

    for j = 1:length(dat)
        datpath = fullfile(maindir,subdir(i).name,dat(j).name);
        fid = fopen(datpath);
        Data{i} = rdsac(datpath);
    end
end

for i = 1:length(subdir)-2
    num{i} = length(Data{1,i+2}.t);
    t1{i} = datetime(Data{1,i+2}.t(1,1),'ConvertFrom','datenum');
    t2{i} = datetime(Data{1,i+2}.t(num{1,i},1),'ConvertFrom','datenum'); 
    figure(1)
    subplot(length(subdir)-2,1,i)
    plot(Data{1,i+2}.t,Data{1,i+2}.d)
%     datetick('x','dd-mmm-yyyy HH:MM:SS','keepticks')
    datetick('x','dd-mmm-yyyy HH:MM:SS')
    grid on
    hold on
end

[x y] = ginput(999);

t_start = datetime(x(1,1),'ConvertFrom','datenum');
t_end = datetime(x(2,1),'ConvertFrom','datenum');

duration = t_end - t_start;
[~,~,~,hours,minutes,Seconds] = datevec(duration);
out_1 = 1000*(3600*hours + 60*minutes + Seconds);
num_1 = round(out_1/(0.002 * 1000));

for i = 1:length(subdir)-2
    intervals{i} = t_start - t1{1,i};
    [~,~,~,hours,minutes,Seconds] = datevec(intervals{1,i});
    out_0{i} = 1000*(3600*hours + 60*minutes + Seconds);
    num_0{i} = round(out_0{1,i}/2);
    data{i} = Data{1,i+2}.d(num_0{1,i}:(num_0{1,i} + num_1)); 
end

%% 计算所选数据信号功率谱

Fs = 500;
N = length(data{1,1});
t = (0:1/Fs:(N-1)/Fs)';

for i = 1:length(subdir)-2
    dataTable{i} = timetable(seconds(t),data{1,i}); 
    [pxx{i},f{i}] = pspectrum(dataTable{1,i});
end

% color = ['m','y','c','g','r','b','k'];

% color = ['r','r','r','r','r','r','g','g','g','g','g','g','b','b','b','b','b','b',...
%     'm','m','m','m','m','m','c','c','c','c','c','c','k','k','k','k','k','k'];

figure(2)

for i = 1:length(subdir)-2
    plot(f{1,i},pow2db(pxx{1,i}),'DisplayName',subdir(i+2).name);
    grid on
    hold on
end

% ylim([0 1])
% set(gca,'YTick',[0:0.1:1])
% xlim([0 100])
% set(gca,'XTick',0:10:100)

legend
xlabel('Frequency (Hz)')
ylabel('Power Spectrum (dB)')
title('Default Frequency Resolution')

figure(3)

for i = 1:length(subdir)-2
    plot(f{1,i},pow2db(pxx{1,i}),'DisplayName',subdir(i+2).name);
    grid on
    hold on
end

% ylim([0 1])
% set(gca,'YTick',[0:0.1:1])
xlim([0 20])
set(gca,'XTick',0:2:20)

legend
xlabel('Frequency (Hz)')
ylabel('Power Spectrum (dB)')
title('Default Frequency Resolution')








