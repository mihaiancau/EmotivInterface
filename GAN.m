%% Transform signals and labels
% Select signals and labels from one subject and trial
% load EpochedData_Training\fc5_va_D1800.mat;

%% Generator Network
% Output: 1 x 231 x 1 array
numFilters = 64;
numLatentInputs = 100;
projectionSize = [1 160 1]; % = N1 projection size is [1 N1 1]
filterSize = 5; % = f1 filter size is [1 f1]


% Network architecture equation 231 = N1 + 15*f1 - 4 (provided stride = 1)
layersGenerator = [
    imageInputLayer([1 numLatentInputs 1],'Normalization','none','Name','in')
    projectAndReshapeLayer(projectionSize,numLatentInputs,'proj');
    transposedConv2dLayer([1 filterSize],4*numFilters,'Name','tconv1') % Activations 1 x 47 x 256
    batchNormalizationLayer('Name','bn1','Epsilon',5e-5)
    reluLayer('Name','relu1')
    transposedConv2dLayer([1 2*filterSize],2*numFilters,'Name','tconv2') % Activations 1 x 78 x 128
    batchNormalizationLayer('Name','bn2','Epsilon',5e-5)
    reluLayer('Name','relu2')
    transposedConv2dLayer([1 4*filterSize],numFilters,'Name','tconv3') % Activations 1 x 141 x 64 
    batchNormalizationLayer('Name','bn3','Epsilon',5e-5)
    reluLayer('Name','relu3')
    transposedConv2dLayer([1 8*filterSize],1,'Name','tconv4') % Activations 1 x 268 x 1
    tanhLayer('Name','tanh')];

lgraphGenerator = layerGraph(layersGenerator);

% 
% %% Discriminator Network
% % Input 1 x 268 x 1 array
% dropoutProb = 0.5;
% numFilters = 64;
% scale = 0.2;
% 
% inputSize = [1 268 1];
% filterSize = 5;
% 
% layersDiscriminator = [
%     imageInputLayer(inputSize,'Normalization','none','Name','in')
%     dropoutLayer(0.5,'Name','dropout')
%     convolution2dLayer(filterSize,numFilters,'Stride',2,'Padding','same','Name','conv1')
%     leakyReluLayer(scale,'Name','lrelu1')
%     convolution2dLayer(filterSize,2*numFilters,'Stride',2,'Padding','same','Name','conv2')
%     batchNormalizationLayer('Name','bn2')
%     leakyReluLayer(scale,'Name','lrelu2')
%     convolution2dLayer(filterSize,4*numFilters,'Stride',2,'Padding','same','Name','conv3')
%     batchNormalizationLayer('Name','bn3')
%     leakyReluLayer(scale,'Name','lrelu3')
%     convolution2dLayer(filterSize,8*numFilters,'Stride',2,'Padding','same','Name','conv4')
%     batchNormalizationLayer('Name','bn4')
%     leakyReluLayer(scale,'Name','lrelu4')
%     convolution2dLayer(4,1,'Name','conv5')];