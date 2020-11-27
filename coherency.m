%-------------------------------------------------------------------------------------%
% Coherency:Finds the magnitude-squared coherence estimate, of the
% input signals, st1、st2、st3、st4、st5、st6...
% Update:2020/08/10;
% Author:Chenlj;
%-------------------------------------------------------------------------------------%



%% 选取数据文件路径，读取子路径文件,计算相关系数

clear all

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
    hold on
end

[x y] = ginput(999);

t_start = datetime(x(1,1),'ConvertFrom','datenum');
t_end = datetime(x(2,1),'ConvertFrom','datenum');

duration = t_end - t_start;
[~,~,~,hours,minutes,seconds] = datevec(duration);
out_1 = 1000*(3600*hours + 60*minutes + seconds);
num_1 = round(out_1/(0.002 * 1000));

for i = 1:length(subdir)-2
    intervals{i} = t_start - t1{1,i};
    [~,~,~,hours,minutes,seconds] = datevec(intervals{1,i});
    out_0{i} = 1000*(3600*hours + 60*minutes + seconds);
    num_0{i} = round(out_0{1,i}/2);
    data{i} = Data{1,i+2}.d(num_0{1,i}:(num_0{1,i} + num_1)); 
end


for i = 1:length(subdir)-2
    temp ='st';
    ResultFile{i} = strcat(temp,int2str(i));
    ResultFile{1,i} = data{1,i};
end

name = combntns(ResultFile,2); 

fs = 500;
noverlap = 512;
N = length(data{1,1});
nfft = 4096; 

% ff = (fs/2000)*(0:2000/2);

for i = 1:length(name)
    [CC{i},f] = mscohere(name{i,1},name{i,2},hanning(nfft),noverlap,nfft,fs);% mscohere 相干系数;
end

len_CC = length(CC{1,1});

Cc = zeros(len_CC,1);

for i = 1:length(name)
    Cc = Cc + CC{1,i};
end

CC_out = Cc./length(name);

figure(2)
plot(f,CC_out,'b','LineWidth',1.5)
    
set(gca,'YTick',[0:0.1:1])
xlim([0 100])
set(gca,'XTick',0:10:100)
ylim([0 1])
xlabel('Frequency','FontSize',11,'FontWeight','normal')
ylabel('Coherence')
grid on
set(gca,'ygrid','on','gridlinestyle','--','Gridalpha',0.4,'LineWidth',0.5)

figure(3)
plot(f,CC_out,'b','LineWidth',1.5)
    
set(gca,'YTick',[0:0.1:1])
xlim([0 20])
set(gca,'XTick',0:2:20)
ylim([0 1])
xlabel('Frequency','FontSize',11,'FontWeight','normal')
ylabel('Coherence')
grid on
set(gca,'ygrid','on','gridlinestyle','--','Gridalpha',0.4,'LineWidth',0.5)





