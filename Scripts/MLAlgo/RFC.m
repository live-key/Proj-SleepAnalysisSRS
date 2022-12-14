% Fit Random Forest Classification model to patient apnea 
% data using power spectra 
% Author: Joe Byrne

clear, clc

% Make output reproducible
rng(42)

% Get tabulated data from patient data prep step
patient = "P1";
dataDir = sprintf("..\\..\\Data\\Database\\%s\\MLDataTable.mat", patient);
load(dataDir)
