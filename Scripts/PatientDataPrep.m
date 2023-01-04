% Get multiple patients' data
% Author: Joe Byrne
function PatientDataPrep(start_patient, end_patient, verbose)

    if nargin == 2; verbose = false; end

    addpath Func
    
    for ii = start_patient:end_patient
        patients(ii) = sprintf("P%s", num2str(ii));
    end
    
    % Analysis start times for each patient
    start_times = { datetime(2020, 1,  8, 20, 51, 00); 
                    datetime(2020, 1,  9, 20, 44, 30);
                    datetime(2020, 1,  9, 20,  4,  0);
                    datetime(2020, 1,  9, 19, 27, 30);
                    datetime(2020, 1, 14, 21, 30,  0); };
    
    % Get patient data in feature vector
    for ii = start_patient:end_patient
        PatientData(patients(ii), start_times{ii}, verbose);
    end
    
    % Compile data into one tabulated form
    all_data = [];
    for ii = start_patient:end_patient
        dataDir = sprintf("../Data/Database/%s/MLDataTable.mat", patients(ii));
        patient_data = load(dataDir);
        all_data = [all_data; patient_data.tabulated_data];
    end
    
    saveDir = sprintf("../Prod/Data/MLAllData.mat");
    save(saveDir, "all_data", "-mat");
    
    if verbose
    fprintf("Saved all patient data to:")
    cprintf("magenta", " \t%s\n\n", saveDir)
    end
end