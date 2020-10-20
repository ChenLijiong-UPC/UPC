%-------------------------------------------------------------------------------------%
% signal_fft:Calculate the fft of signal;
% Update:2020/10/16;
% Author:Chenlj;
%-------------------------------------------------------------------------------------%


%% 选取数据文件路径，读取子路径文件，选取目标数据段

clear all;

filepath = uigetdir('*.*','请选择文件夹');
userpath(filepath);

maindir = filepath;

subdir  = dir( maindir );

for i = 1:length(subdir)
    if( isequal(subdir(i).name, '.')||...
        isequal(subdir(i).name, '..')||...
        ~subdir(i).isdir)
        continue;
    end
    subdirpath = fullfile(maindir,subdir(i).name,'*Z.sac' );
    dat = dir(subdirpath);              

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

%% 计算所选数据信号fft

Fs = 500;
N = length(data{1,1});
t = (0:1/Fs:(N-1)/Fs)';

for i = 1:length(subdir)-2
    sig_fft{i} = fft(data{1,i});
    P2{i} = abs(sig_fft{i}/N);
    P1{i} = P2{1,i}(1:N/2+1);
    P1{i}(2:end-1) = 2*P1{1,i}(2:end-1);  
end

f = Fs*(0:(N/2))/N;

row_1 = input('please input the row of the data:');
column_1 = input('please input the column of the data:');

figure(2)

for i = 1:length(subdir)-2
    subplot(row_1,column_1,i)  % 依据数据个数进行排布
    plot(f,P1{1,i},'DisplayName',subdir(i+2).name)
%     ylim([0 0.05])
%     set(gca,'YTick',[0:0.01:0.05])
    legend
    title('Single-Sided Amplitude Spectrum of X(t)')
    xlabel('f (Hz)')
    ylabel('|P1(f)|')
    grid on
end






