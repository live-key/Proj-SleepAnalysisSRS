% Fit SVM model to patient apnea data using power spectra 
% Author: Joe Byrne

clear, clc

% Make output reproducible
rng(42)

% Get tabulated data from patient data prep step
patient = "P1";
dataDir = sprintf("..\\..\\Data\\Database\\%s\\MLDataTable.mat", patient);
load(dataDir)

% Define SVM object
model = fitcsvm(tabulated_data, labels, 'KernelFunction', 'linear');

% Cross-validate model - 10-fold
CVModel = crossval(model, 'KFold', 10);

% Retrieve percentage success rate
f = kfoldLoss(CVModel);
pct_succ = 1 - f