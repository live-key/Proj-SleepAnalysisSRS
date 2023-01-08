% Pipeline to run all relevant functions in 
% collecting performance data
% Author: Joe Byrne

clear, clc
close all
addpath Func

cprintf("_black", "PIPELINE STARTING\n");

% Patient Combinations
combos = [2, 2, "REM";
          2, 2, "NREM"];

% Run combos
for ii = 1:size(combos, 1)
    % Setup parameters for data prep 
    start_patient = str2num(combos(ii, 1));
    end_patient   = str2num(combos(ii, 2));
    category      = combos(ii, 3);

    cprintf("_black", "\n\nPipeline Iteration %i: Patients %i-to-%i, %s Data\n\n", ...
        ii, start_patient, end_patient, category);

    % Prep the patient data for this run
    PatientDataPrep(start_patient, end_patient, category);
    
    % Train and evaluate model
    cd MLAlgo
    MLAlgo("SVM", category);
    MLAlgo("RFC", category);
    cd ..
end

