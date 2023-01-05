% Get multiple patients' data
% Author: Joe Byrne
function PatientDataPrep(start_patient, end_patient, verbose)

    if nargin == 2; verbose = false; end

    addpath Func
    
    for ii = start_patient:end_patient
        patients(ii) = sprintf("P%s", num2str(ii));
    end
    
    % Analysis start times for each patient
    start_times = { 
                    datetime(2020, 1, 08, 20, 51, 00);  % P1
                    datetime(2020, 1, 09, 20, 44, 30);  % P2
                    datetime(2020, 1, 09, 20, 04, 00);  % P3
                    datetime(2020, 1, 09, 19, 27, 30);  % P4
                    datetime(2020, 1, 14, 21, 30, 00);  % P5
                    datetime(2020, 1, 15, 19, 15, 30);  % P6
                    datetime(2020, 1, 16, 18, 40, 00);  % P7
                    datetime(2020, 1, 22, 20, 05, 30);  % P8
                    datetime(2020, 1, 22, 18, 36, 00);  % P9
                    datetime(2020, 1, 22, 18, 58, 00);  % P10
                    datetime(2020, 1, 23, 20, 30, 30);  % P11
                    datetime(2020, 1, 23, 21, 27, 00);  % P12
                  };
    
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