% Get multiple patients' data
% Author: Joe Byrne

clear, clc
close all

addpath Func

% Setup parameters for data prep 
num_patients = 2;
for ii = 1:num_patients
    patients(ii) = sprintf("P%s", num2str(ii));
end

% Analysis start times for each patient
start_times = { datetime(2020, 1, 8, 20, 35, 52); 
                datetime(2020, 1, 9, 20, 29, 48);  };

% Get patient data in feature vector
for ii = 1:num_patients
    PatientData(patients(ii), start_times{ii});
end

% Combine data into one tabulated form
dataDir = sprintf("../Data/Database/P1/MLDataTable.mat");
all_data = load(dataDir);
for ii = 2:num_patients
    dataDir = sprintf("../Data/Database/%s/MLDataTable.mat", patients(ii));
    patient_data = load(dataDir);
    all_data = [all_data; patient_data];
end

saveDir = sprintf("../Data/Database/MLAllData.mat");
save(saveDir, "all_data", "-mat");
