% Pipeline to test features and find relevant features
% Author: Joe Byrne

%% Manual Setup

clear, clc
close all
addpath Func

cprintf("_black", "PIPELINE STARTING\n");

% Patient Combinations
combos = {
            1, 12;
         };

%% Run Pipeline Combinations

for ii = 1:size(combos, 1)
    % Setup parameters for run 
    run.start_patient = combos{ii, 1};
    run.end_patient   = combos{ii, 2};
    run.category      = "All";
    run.split         = "PWISE";
    run.verbose       = true;
    run.recalc        = false;

    cprintf("_black", "\n\nPipeline Iteration %i: %s Patients %i-to-%i, %s Data\n\n", ...
        ii, run.split, run.start_patient, run.end_patient, run.category);

    % Prep the patient data for this run
    run = PatientDataPrep(run);    
    
    % Get all data
    data = load(run.filePath).all_data;
    
    % Train model on isolated feature
    vars = data.Properties.VariableNames;
    
    % Isolate features
    iso = GetSubTable(data, ["_3", "_4", "_5"], true);
    iso = GetSubTable(iso, "STAGE", false);
    sleep = GetSubTable(data, "STAGE_1", true);
    lab = GetSubTable(data, "LABEL", true);
    iso = [iso, sleep, lab];
    save(run.filePath, "iso", "-append");
    
    % Train and evaluate model
    cd MLAlgo
        perf = MLAlgo("RFC", run, false);
    cd ..
    
end

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

<<<<<<< HEAD
    eeg_cell = "C4";
    ssd_cell = "C37";
=======
    eeg_cell = "F4";
    ssd_cell = "F37";
>>>>>>> 4151cd3 (feature selection startegies)
    
    % Write data to template file for results
    err = true;
    while err
        try 
            ProcWrite(w(1:30), filePath, sheet, eeg_cell);
            ProcWrite(w(31:end), filePath, sheet, ssd_cell);
            
            fprintf("Data written to file:\t%s\n", filePath)
            
            err = false;
            winopen(filePath)
        catch 
            input("Can't save the file - have you closed the file you are trying to write to?:", 's')
            err = true;
        end
    end
end

