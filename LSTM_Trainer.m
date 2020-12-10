%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LSTM network for classification of error-related potentials %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load EpochedData_Training\fc5_va_D1800.mat % here path to EpochedData_Training sample

summary(Labels);
% A = Epoch with error-related potential
% N = Standard epoch

% Train the Classifier Using Raw Signal Data

% Split the signals according to their class.
erpX = Signals(Labels=='A');
erpY = Labels(Labels=='A');

normalX = Signals(Labels=='N');
normalY = Labels(Labels=='N');

[trainIndA,valIndA,testIndA] = dividerand(length(Labels(Labels=='A')),0.8,0.1,0.1);
[trainIndN,valIndN,testIndN] = dividerand(length(Labels(Labels=='N')),0.8,0.1,0.1);

XTrainA = erpX(trainIndA);
YTrainA = erpY(trainIndA);

XTrainN = normalX(trainIndN);
YTrainN = normalY(trainIndN);

XValA = erpX(valIndA);
YValA = erpY(valIndA);

XValN = normalX(valIndN);
YValN = normalY(valIndN);

XTestA = erpX(testIndA);
YTestA = erpY(testIndA);

XTestN = normalX(testIndN);
YTestN = normalY(testIndN);

% To achieve the same number of signals in each class
XTrain = [repmat(XTrainA(1:length(XTrainA)),floor(length(XTrainN)/length(XTrainA)),1); XTrainN(1:length(XTrainA)*floor(length(XTrainN)/length(XTrainA)))];
YTrain = [repmat(YTrainA(1:length(YTrainA)),floor(length(YTrainN)/length(YTrainA)),1); YTrainN(1:length(YTrainA)*floor(length(YTrainN)/length(YTrainA)))];
XVal = [repmat(XValA(1:length(XValA)),floor(length(XValN)/length(XValA)),1); XValN(1:length(XValA)*floor(length(XValN)/length(XValA)))];
YVal = [repmat(YValA(1:length(YValA)),floor(length(YValN)/length(YValA)),1); YValN(1:length(YValA)*floor(length(YValN)/length(YValA)))];
XTest = [repmat(XTestA(1:length(XTestA)),floor(length(XTestN)/length(XTestA)),1); XTestN(1:length(XTestA)*floor(length(XTestN)/length(XTestA)))];
YTest = [repmat(YTestA(1:length(YTestA)),floor(length(YTestN)/length(YTestA)),1); YTestN(1:length(YTestA)*floor(length(YTestN)/length(YTestA)));];
summary(YTrain)
summary(YVal)
summary(YTest)
% Define the LSTM Network Architecture
layers = [ ...
    sequenceInputLayer(1)
    bilstmLayer(100,'OutputMode','last')
    fullyConnectedLayer(2)
    softmaxLayer
    classificationLayer
    ];
options = trainingOptions('adam', ...
    'MaxEpochs',5, ...
    'MiniBatchSize', 50, ...
    'InitialLearnRate', 0.01, ...
    'ValidationData',{XVal,YVal}, ...
    'ValidationFrequency',5, ...
    'SequenceLength', 1000, ...
    'GradientThreshold', 1, ...
    'ExecutionEnvironment',"auto",...
    'plots','training-progress', ...
    'Verbose',false);
% Train the LSTM Network
net = trainNetwork(XTrain,YTrain,layers,options);
% Visualize the Training and Testing Accuracy
trainPred = classify(net,XTrain,'SequenceLength',1000);
LSTMAccuracyTrain = sum(trainPred == YTrain)/numel(YTrain)*100;
figure
confusionchart(YTrain,trainPred,'ColumnSummary','column-normalized',...
              'RowSummary','row-normalized','Title','Training Prediction Confusion Chart for LSTM');
% Now classify the testing data with the same network.
testPred = classify(net,XTest,'SequenceLength',1000);
% Calculate the testing accuracy and visualize the classification performance as a confusion matrix
LSTMAccuracyTest = sum(testPred == YTest)/numel(YTest)*100;

figure
confusionchart(YTest,testPred,'ColumnSummary','column-normalized',...
              'RowSummary','row-normalized','Title','Testing Prediction Confusion Chart for LSTM');
