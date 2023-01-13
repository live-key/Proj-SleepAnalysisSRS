% Get multiple patients' data
% Author: Joe Byrne
function run = PatientDataPrep(run)
    
    sp          = run.start_patient;
    ep          = run.end_patient;
    category    = run.category;
    split       = run.split;
    recalc      = run.recalc;
    verbose     = run.verbose;

    % Check save file doesn't exist
    saveDir = sprintf("../Prod/MLData");
    saveFile = sprintf("%s/%i-%i_%s_%s_Data.mat", saveDir, sp, ep, category, split);
    run.filePath = saveFile;

    if isfile(saveFile) && ~recalc; return; end
    
    addpath Func
    addpath MLAlgo/Func
    
    for ii = sp:ep
        patients(ii) = sprintf("P%s", num2str(ii));
    end

    split = split.upper();
    prefix = "../Data";  % "F:"  _or_  "../Data", in my case
    
    % Analysis start times for each patient
    start_times = load("../Prod/Manual/patient_analysis_start.mat").start_times;

    % Apnea Hypopnea Index for each patient
    AHI = load("../Prod/Manual/patient_ahi.mat").AHI;
    
    % Get patient data in feature vector
    if recalc
        for ii = sp:ep
            PatientData(patients(ii), start_times{ii}, verbose);
        end
    end

    if split == "PWISE"
        % Discretise data per patient
        % ------------------- %
        % Compile data into one cell array
        all_data = cell(ep-sp+1, 1);
        for ii = sp:ep
            dataDir = sprintf("%s/Database/%s/MLDataTable.mat", prefix, patients(ii));
            patient_data = load(dataDir);
            all_data{ii-sp+1, 1} = patient_data.tabulated_data;
        end
        all_data = CellCat(all_data);
    else
        % Pool data
        % ------------------- %
        % Compile data into one tabulated form
        all_data = [];
        for ii = sp:ep
            dataDir = sprintf("%s/Database/%s/MLDataTable.mat", prefix, patients(ii));
            patient_data = load(dataDir);
            all_data = [all_data; patient_data.tabulated_data];
        end
    end
    
    % Seperate data if user so desires
    if category == "REM"
        cat = "STAGE_4";
        cat_tab = table2array(GetSubTable(all_data, cat, true));
        all_data = GetSubTable(all_data(logical(cat_tab), :), "STAGE", false);
    
    elseif category == "NREM"
        cat = ["STAGE_1", "STAGE_2", "STAGE_3"];
        cat_tab = table2array(GetSubTable(all_data, cat, true));
        cat_idx = cat_tab(:, 1) + cat_tab(:, 2) + cat_tab(:, 3); 
        all_data = GetSubTable(all_data(logical(cat_idx), :), "STAGE", false);
    end
    
    try
        save(saveFile, "all_data", "-mat");
    catch
        if verbose; fprintf("Making Directory:\t%s\n", saveDir); end
        mkdir(saveDir)
        save(saveFile, "all_data", "-mat");
    end

    if verbose
    fprintf("Saved all patient data to:")
    cprintf("magenta", " \t%s\n\n", saveDir)
    end
end