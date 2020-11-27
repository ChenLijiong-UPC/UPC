%-------------------------------------------------------------------------------------%
% data_merge:merge the ".sac" data;
% Update:2020/09/18;
% Author:Chenlj;
%-------------------------------------------------------------------------------------%


%% 选取数据文件路径，读取文件

filepath = uigetdir('*.*','请选择文件夹');
userpath(filepath);
dirOutput = dir(fullfile(filepath,'*Z.sac'));
fileNames = {dirOutput.name}';

len = length(fileNames);

for i = 1:len
    D{i} = rdsac(char(fileNames(i,1)));
    num{i} = length(D{1,i}.t);
    t_start{i} = datetime(D{1,i}.t(1,1),'ConvertFrom','datenum');
    t_end{i} = datetime(D{1,i}.t(num{1,i},1),'ConvertFrom','datenum'); 
end

%% 

for i = 1:length(subdir)-2
    num{i} = length(Data{1,i+2}.t);
    t1{i} = datetime(Data{1,i+2}.t(1,1),'ConvertFrom','datenum');
    t2{i} = datetime(Data{1,i+2}.t(num{1,i},1),'ConvertFrom','datenum'); 
    figure(1)
    subplot(length(subdir)-2,1,i)
    plot(Data{1,i+2}.t,Data{1,i+2}.d)
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

%%

Fs = 500;
N = length(data{1,1});
t = (0:1/Fs:(N-1)/Fs)';

for i = 1:length(subdir)-2
    dataTable{i} = timetable(seconds(t),data{1,i}); 
    [pxx{i},f{i}] = pspectrum(dataTable{1,i});
end

figure(2)
color = ['m','y','c','g','r','b','k'];
for i = 1:length(subdir)-2
    plot(f{1,i},pow2db(pxx{1,i}),color(i));
%     xlim([0 50])
    grid on
    hold on
end
legend('1','2','3','4','5','6','7')
xlabel('Frequency (Hz)')
ylabel('Power Spectrum (dB)')
title('Default Frequency Resolution')










