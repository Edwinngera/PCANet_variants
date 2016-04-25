% PCANet for feature extractor
% input:2fold 58*2 images
% out: feature:2048*9801
clear all;

PCANet.NumStages = 2;
PCANet.PatchSize = 7;
PCANet.NumFilters = [8 8];
PCANet.HistBlockSize = [7 7]; 
PCANet.BlkOverLapRatio = 0.5;

fprintf('\n ====== PCANet Parameters ======= \n')
PCANet
% paramerters setting
Ntrain = 58; % ȡ58��ͼѵ��;
nTestImg = 58;
% a�ɸá�a=randperm(195426);���������;
load('C:\Shu\data\a1');

data_dir = 'C:\Shu\image\TCB_Challenge_Data';
dataSet = 'TRAIN_TEST_DATA';
rt_data_dir = fullfile(data_dir, dataSet);% data\Caltch101
subfolders = dir(rt_data_dir);% �� �� ��;

sift_all = cell(116,1);
train = cell(58,1);
feaPCA = cell(116,1);

            
for ii = 1:length(subfolders),
    subname = subfolders(ii).name; % �ļ��е����ƣ��ͷֻ��£��зֻ��£��߷ֻ��£�
    
    if ~strcmp(subname, '.') && ~strcmp(subname, '..'),
%         database.nclass = database.nclass + 1;
        
%         database.cname{database.nclass} = subname;
        
        frames = dir(fullfile(rt_data_dir, subname, '*.tif'));% .mat �ļ���·��;
        
        c_num = length(frames); % �ļ�����.mat�ļ�����Ŀ;  
        
    
%         if ~isdir(feapath),
%             mkdir(feapath);% �����ļ��� subname�ļ���
%         end;
        
        for jj = 1:c_num,   % c_num*length(subfolders)= ͼƬ����;
            imgpath = fullfile(rt_data_dir, subname, frames(jj).name);% frames��jj��.name��·��
            
            I = imread(imgpath);
            sift_all{((ii-3)*58+jj),1} =double(I);
            
         
        end;    
    end;
end;

% �������ļ��г�ȡѵ��������һ��ͼƬ������RGB���㣻
% ȡѵ������ ;
TrnData_ImgCell = {sift_all{a(1:Ntrain),:}}';
TestData_ImgCell = {sift_all{a(Ntrain+1:end),:}}';
fprintf('\n ====== PCANet Training ======= \n')
[ftrain V BlkIdx] = feaPCANet_train(TrnData_ImgCell,PCANet,1); 
fprintf('\n ====== PCANet Testing ======= \n')
for idx = 1:1:116
    
    feaPCA{idx,1} = feaPCANet_FeaExt(sift_all(idx),V,PCANet); % extract a test feature using trained PCANet model 

    
end




    