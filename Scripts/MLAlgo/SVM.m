% Fit SVM model to patient apnea data using power spectra 
% Author: Joe Byrne

clear, clc

% Make output reproducible
rng(42)

% Get tabulated data from patient data prep step
patient = "P1";
dataDir = sprintf("..\\..\\Data\\Database\\%s\\MLDataTable.mat", patient);
load(dataDir)

% Partition the data into testing and training data
cv = cvpartition(size(tabulated_data, 1), 'HoldOut', 0.2);

testIndex = cv.test;
train = tabulated_data(~testIndex, :);
test  = tabulated_data(testIndex, :);

% Define SVM object
model = fitcsvm(train, labels(~testIndex), 'KernelFunction', 'linear');

% Cross-validate model - 10-fold
CVModel = crossval(model, 'KFold', 10);

% Retrieve percentage success rate
f = kfoldLoss(CVModel);
fprintf("CrossVal Success Rate: \t%.2f%%\n", 100*(1 - f));

% Use model to predict on test set
prediction = predict(model,test);
performance = prediction == labels(testIndex);
fprintf("Overall Performance: \t%.2f%%\n", 100*(mean(performance)));



