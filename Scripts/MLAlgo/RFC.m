% Fit Random Forest Classification model to patient apnea 
% data using power spectra 
% Author: Joe Byrne

% clear, clc
addpath Func

% Make output reproducible
rng(42)

% Get tabulated data from patient data prep step
patient = "P1";
dataDir = sprintf("../../Data/Database/%s/MLDataTable.mat", patient);

load(dataDir)

% Divide into apnea/no-apnea for subsampling
data_apnea = tabulated_data(tabulated_data.LABEL == 1, :);
data_noapn = tabulated_data(tabulated_data.LABEL == 0, :);

% Partition the data into testing and training data
[apnea_train, apnea_test] = SubSampleSplit(data_apnea);
[noapn_train, noapn_test] = SubSampleSplit(data_noapn);

% Combine into overall data
train = [apnea_train; noapn_train];
train_labels = train.LABEL;
train.LABEL = [];

test  = [apnea_test; noapn_test];
test_labels = test.LABEL;
test.LABEL = [];

% Define RFC object
model = fitensemble(train, train_labels, 'Bag', 100, 'Tree', 'Type', 'classification');

% Cross-validate model - 10-fold
CVModel = crossval(model, 'KFold', 10);

% Retrieve percentage success rate
f = kfoldLoss(CVModel);
fprintf("CrossVal Success Rate: \t%.2f%%\n", 100*(1 - f));

% Use model to predict on test set
prediction = predict(model,test);
performance = prediction == test_labels;
fprintf("Overall Performance: \t%.2f%%\n", 100*(mean(performance)));

% Shuffle training labels up
train_labels = train_labels(randperm(length(train_labels)));

% Define shuffled SVM model
model_shuf = fitcsvm(train, train_labels, 'KernelFunction', 'linear');

% Use model to predict on test set
prediction = predict(model_shuf,test);
performance = prediction == test_labels;
fprintf("Shuffled Performance: \t%.2f%%\n\n", 100*(mean(performance)));
