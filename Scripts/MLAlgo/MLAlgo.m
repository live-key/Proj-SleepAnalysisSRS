% Fit ML model to patient apnea data using power spectra 
% Author: Joe Byrne

%% Setup

disp("Setting Up Workspace...");

clear, clc
addpath Func

model_label = "SVM";

% Make output reproducible
rng(42)

% Get all data
dataDir = sprintf("../../Data/Database/MLAllData.mat");
data = load(dataDir).all_data;

%% Data split

disp("Splitting Data...");

% Divide into apnea/no-apnea for subsampling
data_apnea = data(data.LABEL == 1, :);
data_noapn = data(data.LABEL == 0, :);

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

%% Train model

fprintf("Training Base %s Model...\n", model_label);

if model_label == "SVM"
    % Define SVM object
    model = fitcsvm(train, train_labels, 'KernelFunction', 'linear');
elseif model_label == "RFC"
    % Define RFC object
    model = fitensemble(train, train_labels, 'Bag', 100, 'Tree', 'Type', 'classification');
end

%% Test model

disp("Cross-Validating Base Model...");

% Cross-validate model - 10-fold
CVModel = crossval(model, 'KFold', 10);

% Retrieve percentage success rate
f = kfoldLoss(CVModel);
fprintf("CrossVal Success Rate: \t%.2f%%\n", 100*(1 - f));

% Use model to predict on test set
prediction = predict(model,test);
fprintf("Matthews Correlation: \t%.2f%%\n\n", 100*MCC(prediction, test_labels));

%% Shuffle test

disp("Shuffling Data for Model...");
% Shuffle training labels up
train_labels_shuff = train_labels(randperm(length(train_labels)));

fprintf("Training Shuffled %s Model...\n", model_label);
if model_label == "SVM"
    % Define shuffled SVM model
    model_shuf = fitcsvm(train, train_labels_shuff, 'KernelFunction', 'linear');
elseif model_label == "RFC"
    % Define shuffled SVM model
    model_shuf = fitensemble(train, train_labels_shuff, 'Bag', 100, 'Tree', 'Type', 'classification');
end

disp("Cross-Validating Shuffled Model...");

% Cross-validate model - 10-fold
cv_model_shuff = crossval(model_shuf, 'KFold', 10);

% Retrieve percentage success rate
f = kfoldLoss(cv_model_shuff);
fprintf("Shuffle CrossVal Success: \t%.2f%%\n", 100*(1 - f))

% Use model to predict on test set
prediction = predict(model_shuf,test);
fprintf("Matthews Correlation: \t\t%.2f%%\n\n", 100*MCC(prediction, test_labels));
