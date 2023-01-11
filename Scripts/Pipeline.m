% Pipeline to run all relevant functions in 
% collecting performance data
% Author: Joe Byrne

clear, clc
close all
addpath Func

cprintf("_black", "PIPELINE STARTING\n");

write2excel = true; 

% Patient Combinations
combos = [
            1, 3, "All", "PWISE";
            1, 5, "All", "PWISE";
            1, 6, "All", "PWISE";
            7, 12, "All", "PWISE";
            1, 12, "All", "PWISE";
            1, 12, "REM", "PWISE";
            1, 12, "NREM", "PWISE";
         ];

% Run combos
for ii = 1:size(combos, 1)
    % Setup parameters for data prep 
    start_patient = str2num(combos(ii, 1));
    end_patient   = str2num(combos(ii, 2));
    category      = combos(ii, 3);
    split         = combos(ii, 4);

    cprintf("_black", "\n\nPipeline Iteration %i: Patients %i-to-%i, %s Data\n\n", ...
        ii, start_patient, end_patient, category);

    % Prep the patient data for this run
    PatientDataPrep(start_patient, end_patient, category, split);
    
    % Train and evaluate model
    cd MLAlgo
    [svm(ii, 1), svm(ii, 2), svm(ii, 3), svm(ii, 4)] = MLAlgo("SVM", category, split);
    [rfc(ii, 1), rfc(ii, 2), rfc(ii, 3), rfc(ii, 4)] = MLAlgo("RFC", category, split);
    cd ..
end

% Write data to results file
if write2excel
        resultsDir = sprintf("../Deliverables/PerformanceRecord.xlsx");

        svm_cell = "B3";
        rfc_cell = sprintf("B%i", 3+1+size(combos, 1));
        
        err = true;
        
        while err
            try 
                svm_c = num2cell(svm);
                rfc_c = num2cell(rfc);

                svm_c(isnan(svm)) = {'NaN'};
                rfc_c(isnan(rfc)) = {'NaN'};

                writecell(svm_c, resultsDir, 'Sheet', 'Patient-Wise Data', 'Range', svm_cell, 'AutoFitWidth', false);
                writecell(rfc_c, resultsDir, 'Sheet', 'Patient-Wise Data', 'Range', rfc_cell, 'AutoFitWidth', false);
                
                fprintf("Data written to file:\t%s\n", resultsDir)
                
                err = false;
                winopen(resultsDir)
            catch 
                input("Can't save the file - have you closed the file you are trying to write to?:", 's')
                err = true;
            end
        end
end

