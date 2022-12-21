% Get multiple patients' data
% Author: Joe Byrne

clear, clc
close all

addpath Func

% Setup parameters for data prep 
num_patients = 2;
start_patient = 1;

for ii = 1:num_patients
    patients(ii) = sprintf("P%s", num2str(ii));
end

% Analysis start times for each patient
start_times = { datetime(2020, 1, 8, 20, 51, 00); 
                datetime(2020, 1, 9, 20, 44, 30);
                datetime(2020, 1, 9, 20,  4,  0);
                datetime(2020, 1, 9, 19, 27, 30); };

% Get patient data in feature vector
for ii = start_patient:num_patients
    PatientData(patients(ii), start_times{ii});
end

% Compile data into one tabulated form
dataDir = sprintf("../Data/Database/P1/MLDataTable.mat");
all_data = load(dataDir).tabulated_data;
for ii = 1:num_patients
    dataDir = sprintf("../Data/Database/%s/MLDataTable.mat", patients(ii));
    patient_data = load(dataDir);
    all_data = [all_data; patient_data.tabulated_data];
end

saveDir = sprintf("../Data/Database/MLAllData.mat");
save(saveDir, "all_data", "-mat");
