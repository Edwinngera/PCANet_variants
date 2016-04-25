%%%%%%%%%%%%%%%%%%%%%%%%%
% PCANet for Cell_He
% input images
% random 10000 patch to train filter
% output;feature&Filter&accuracy
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% PCANet for feature extractor
% input:images
% out: V
% clear all;

tic;
%% parameter setting
PCANet.NumStages = 2;
PCANet.PatchSize = 16;
PCANet.NumFilters = [8 8];
PCANet.HistBlockSize = [16 16]; 
PCANet.BlkOverLapRatio = 0;

fprintf('\n ====== PCANet Parameters ======= \n')
PCANet


Img_dir = 'E:\QGANet\Image';
data_dir = 'E:\QGANet\Data\Caltech101';
dataSet = 'Caltech101';
% dataSet = 'Hematoxylin';
% dataSet = 'eosin';
% dataSet='TRAIN_TEST_Data';
%% 
skip_filter = false;
rt_data_dir = fullfile(data_dir, dataSet);% data\Caltch101
rt_Img_dir = fullfile(Img_dir, dataSet);
subfolders = dir(rt_Img_dir);% �� �� ��;
NumImg = 66;
sift_all = cell(NumImg,1);
% train = cell(Ntrain,1);
counter = 0; % 

if ~skip_filter
%% get the training sample           
for ii = 1:length(subfolders),
    subname = subfolders(ii).name; % �ļ��е����ƣ��ͷֻ��£��зֻ��£��߷ֻ��£�
    
    if ~strcmp(subname, '.') && ~strcmp(subname, '..'),
        
        frames = dir(fullfile(rt_Img_dir, subname, '*.jpg'));% .mat �ļ���·��;
        
        c_num = length(frames); % �ļ�����.mat�ļ�����Ŀ;  
        for jj = 1:c_num,   % c_num*length(subfolders)= ͼƬ����;
            imgpath = fullfile(rt_Img_dir, subname, frames(jj).name);% frames��jj��.name��·��
          I = Image2Qua(im2double(imread(imgpath)));% ��ɫͼ��ͼ��ת��Ϊ��Ԫ����   
            counter = counter+1;
            sift_all{counter,1} = I;
        end;   
     end;    
end;
TrnData_ImgCell = sift_all;

%% calculate QGANet Filter
fprintf('\n ====== PCANet Training ======= \n')
[ftrain V BlkIdx] = feaQGANet_train_cell(TrnData_ImgCell,PCANet,0); 
save('E:\QGANet\Data\Caltech101\V','V');
else
load('E:\QGANet\Data\Caltech101\V','V');
end
%% calculate the QGANet feature
for ii = 1:length(subfolders),
    subname = subfolders(ii).name; 
    
    if ~strcmp(subname, '.') && ~strcmp(subname, '..'),
        
        frames = dir(fullfile(rt_Img_dir, subname, '*.jpg'));% .mat �ļ���·��;
        
        c_num = length(frames); % �ļ�����.mat�ļ�����Ŀ;  
        
        feapath = fullfile(rt_data_dir, subname);
        if ~isdir(feapath),
            mkdir(feapath);% �����ļ��� subname�ļ���
        end;
        
        for jj = 1:c_num,   % c_num*length(subfolders)= ͼƬ����;
            imgpath = fullfile(rt_Img_dir, subname, frames(jj).name);% frames��jj��.name��·��
             fprintf('Processing %s: \n', ...
                     frames(jj).name);
            I = im2double(imread(imgpath));
            I_cell ={Image2Qua(I)};  % convert RGB image to quaternion
            feaSet.feaArr = feaQGANet_FeaExt(I_cell,V,PCANet); % ������ȡ
            
            [pdir, fname] = fileparts(frames(jj).name);                        
            fpath = fullfile(rt_data_dir, subname, [fname, '.mat']);
            
            save(fpath, 'feaSet');

        end;    
    end;
end;

%% SPM and SVM
database_create_cell;
SPM_cell;
SVM_Loo_cell;