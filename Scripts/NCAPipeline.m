% Pipeline to run NCA 
% Author: Joe Byrne

%% Manual Setup

clear, clc
close all
addpath Func

rng(2)

cprintf("_black", "PLOTTING PC1-PC2 SCATTER");

% Setup parameters for run 
run.start_patient = 1;
run.end_patient   = 12;
run.category      = "All";
run.split         = "POOL";
run.verbose       = true;
run.recalc        = false;

% Prep the patient data for this run
run = PatientDataPrep(run);    

% Get all data
data = load(run.filePath).all_data;
ap_loc = logical(data.LABEL);

x = GetSubTable(data, "LABEL", false);
x = table2array(x);
y = data.LABEL;

mdl = fscnca(x,y,'Solver','sgd','Verbose', int8(run.verbose));

vars = data.Properties.VariableNames;
w = [mdl.FeatureWeights; 0];
mdl_sat = w > 2.5;
iso_vars = convertCharsToStrings(vars(mdl_sat == true));

iso = GetSubTable(data, [iso_vars, "LABEL"], true);
save(run.filePath, "iso", "-append");

% Train and evaluate model
cd MLAlgo
    perf = MLAlgo("RFC", run, false);
cd ..


