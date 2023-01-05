% Pipeline to run all relevant functions in 
% collecting performance data
% Author: Joe Byrne

clear, clc
close all

cprintf("_black", "PIPELINE STARTING\n");

% Patient Combinations
combos = [6, 6; 7, 7; 8, 8; 9, 9; 
          10, 10; 11, 11; 12, 12;
          1, 6; 7, 12; 1, 12];

% Run combos
for ii = 1:size(combos, 1)
    % Setup parameters for data prep 
    start_patient = combos(ii, 1);
    end_patient   = combos(ii, 2);

    cprintf("_black", "\n\nPipeline Iteration %i: Patients %i-to-%i\n\n", ...
                                        ii, start_patient, end_patient);

    % Prep the patient data for this run
    PatientDataPrep(start_patient, end_patient);
    
    % Train and evaluate model
    cd MLAlgo
    MLAlgo("SVM");
    MLAlgo("RFC");
    cd ..
end

