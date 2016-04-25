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


Img_dir = 'F:\PCA_2_9\Image';
data_dir = 'F:\PCA_2_9\Data\PCANet_Cell_gray\1';

% dataSet = 'Hematoxylin';
% dataSet = 'eosin';
dataSet='Caltech101';
%% 
skip_filter = true;
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
            I = im2double(rgb2gray(imread(imgpath)));
            counter = counter+1;
            sift_all{counter,1} = I;
        end;   
     end;    
end;
% TrnData_ImgCell = {sift_all{c(1:Ntrain),:}}';

% ����ͼƬ�����ȡpatch; 
TrnData_ImgCell = sift_all;

%% calculate PCANet Filter
fprintf('\n ====== PCANet Training ======= \n')
[ftrain V BlkIdx] = feaPCANet_train(TrnData_ImgCell,PCANet,0); 
save('C:\Shu\Data\PCANet_Cell_gray\1\TI\V','V');
else
% load('C:\Shu\Data\PCANet_Cell_gray\1\V','V');
load('E:\Miccai\Cell_GAPCANet\GA_1\V')
% %% randnet  randn_orth
% temp = zeros(256,16);
% for i=1:16
% randnpatch = orth(randn(16,16));
%  temp(:,i) = randnpatch(:);
% end
% V{1,1} = temp(:,1:8);
% V{2,1} = temp(:,9:16);
end
%% calculate the PCANet feature
for ii = 1:length(subfolders),
    subname = subfolders(ii).name; % �ļ��е����ƣ��ͷֻ��£��зֻ��£��߷ֻ��£�
    
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
            I = rgb2gray(imread(imgpath));
            I_cell ={im2double(I)};
            feaSet.feaArr = [feaPCANet_FeaExt(I_cell,V,PCANet)]; % extract a test feature using trained PCANet model
            
            [pdir, fname] = fileparts(frames(jj).name);                        
            fpath = fullfile(rt_data_dir, subname, [fname, '.mat']);
            
            save(fpath, 'feaSet');

        end;    
    end;
end;




%% PCANet _ SVM
%resharp
database_create;

numFea = length(database.path);% ͼƬ����

    fpath = database.path{1};
    load(fpath);% ����һ��ͼƬ��feaSet
 [m,n]=   size(feaSet.feaArr);
PCA_fea = zeros(m*n, numFea);
PCA_label = zeros(numFea, 1);%Ԫ��Ϊ0��������

disp('==================================================');
% fprintf('Calculating the sparse coding feature...\n');
% fprintf('Regularization parameter: %f\n', gamma);
disp('==================================================');

for iter1 = 1:numFea,  
    if ~mod(iter1, 50),
        fprintf('.\n');
    else
        fprintf('.');
    end;
    fpath = database.path{iter1};
    load(fpath);% ����һ��ͼƬ��feaSet
    PCA_fea(:,iter1) = reshape(feaSet.feaArr,m*n,1);
    PCA_label(iter1) = database.label(iter1);
end;
%% sample
% load('C:\Shu\PCAnet\data\a');

%% data of PCANet feature

%a = randperm(num);
tr_num = Ntrain;
train_label = PCA_label(a(1:tr_num));
train = PCA_fea(:,a(1:tr_num))';
test_label = PCA_label(a(tr_num+1:end));
test =  PCA_fea(:,a(tr_num+1:end))';

%% PCANet parameters
model = svmtrain(train_label,train,'-t 0 -s 1 -q');
[C1, acc , dec_values] = svmpredict(test_label,test,model);
toc
