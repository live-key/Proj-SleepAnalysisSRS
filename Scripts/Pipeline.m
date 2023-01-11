% Pipeline to run all relevant functions in 
% collecting performance data
% Author: Joe Byrne

%% Manual Setup

clear, clc
close all
addpath Func

cprintf("_black", "PIPELINE STARTING\n");

% Patient Combinations
combos = {
            1, 3, "All", "POOL";
            1, 5, "All", "POOL";
            1, 6, "All", "POOL";
            7, 12, "All", "POOL";
         };

%% Run Pipeline Combinations

for ii = 1:size(combos, 1)
    % Setup parameters for run 
    run.start_patient = combos{ii, 1};
    run.end_patient   = combos{ii, 2};
    run.category      = combos{ii, 3};
    run.split         = combos{ii, 4};
    run.verbose       = false;
    run.recalc        = false;

    cprintf("_black", "\n\nPipeline Iteration %i: %s Patients %i-to-%i, %s Data\n\n", ...
        ii, run.split, run.start_patient, run.end_patient, run.category);

    % Prep the patient data for this run
    run = PatientDataPrep(run);
    
    % Train and evaluate model
    cd MLAlgo
    svm(ii, :) = MLAlgo("SVM", run);
    rfc(ii, :) = MLAlgo("RFC", run);
    cd ..
end

%% Write Data to Results File

if input("Write to Excel file? (y/n): ", 's') == "y"
    % Get valid file path and sheet name
    resultsDir = sprintf("../Deliverables");
    fileName = input("Please input desired filename to write results to: ", 's');
    
    filePath = sprintf("%s/%s.xlsx", resultsDir, fileName);
    while ~isfile(filePath)
        fileName = input("Input file does not exist.  Please input a valid Excel filename from Deliverables directory: ", 's');
        filePath = sprintf("%s/%s.xlsx", resultsDir, fileName);
    end

    sheet = input("Please input desired sheet to write results to: ", 's');
    
    [~,sheetNames] = xlsfinfo(filePath);
    sheetValid = any(strcmp(sheetNames, sheet));

    while ~sheetValid
        sheet = input("Input sheet does not exist.  Please input a valid Excel worksheet from given file: ", 's');
        [~,sheetNames] = xlsfinfo(filePath);
        sheetValid = any(strcmp(sheetNames, sheet));
    end

    svm_cell = input("Please input start cell for SVM data: ", 's');
    rfc_cell = sprintf("B%i", 3+1+size(combos, 1));
    
    % Write data to template file for results
    err = true;
    while err
        try 
            ProcWrite(svm, filePath, sheet, svm_cell);
            ProcWrite(rfc, filePath, sheet, rfc_cell);
            
            fprintf("Data written to file:\t%s\n", filePath)
            
            err = false;
            winopen(filePath)
        catch 
            input("Can't save the file - have you closed the file you are trying to write to?:", 's')
            err = true;
        end
    end
end

