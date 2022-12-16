% Fit Random Forest Classification model to patient apnea 
% data using power spectra 
% Author: Joe Byrne

clear, clc
addpath Func\

% Make output reproducible
rng(42)

% Get tabulated data from patient data prep step
patient = "P1";
dataDir = sprintf("..\\..\\Data\\Database\\%s\\MLDataTable.mat", patient);
load(dataDir)

% Divide into apnea/no-apnea for subsampling
data_apnea = tabulated_data(labels == 1, :);
data_noapn = tabulated_data(labels == 0, :);

% Partition the data into testing and training data
[apnea_train, apnea_test] = SubSampleSplit(data_apnea);
[noapn_train, noapn_test] = SubSampleSplit(data_noapn);

% Combine into overall data
train = [apnea_train; noapn_train];
test  = [apnea_test; noapn_test];

% Define RFC object
model = fitensemble(train, labels(~testIndex), 'Bag', 100, 'Tree', 'Type', 'classification');

% Cross-validate model - 10-fold
CVModel = crossval(model, 'KFold', 10);

% Retrieve percentage success rate
f = kfoldLoss(CVModel);
fprintf("CrossVal Success Rate: \t%.2f%%\n", 100*(1 - f));

% Use model to predict on test set
prediction = predict(model,test);
performance = prediction == labels(testIndex);
fprintf("Overall Performance: \t%.2f%%\n", 100*(mean(performance)));
