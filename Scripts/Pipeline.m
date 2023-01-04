% Pipeline to run all relevant functions in 
% collecting performance data
% Author: Joe Byrne

clear, clc
close all

cprintf("_black", "PIPELINE STARTING\n");

% Patient Combinations
combos = [1, 1; 2, 2; 3, 3; 4, 4; 
          5, 5; 1, 3; 1, 5];

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

