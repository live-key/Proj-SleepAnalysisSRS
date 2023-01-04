% Get multiple patients' data
% Author: Joe Byrne

clear, clc
close all

addpath Func

% Setup parameters for data prep 
start_patient = 1;
end_patient   = 1;

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
    PatientData(patients(ii), start_times{ii});
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

% Check for overall sleep stage overlap
sleep_stage = table2array(GetSubTable(all_data, "STAGE", true));
mus = mean(sleep_stage, 2);
if mus(mus > 0.2)
    cprintf('_red', '%i ', size(mus(mus > 0.2),1));
    cprintf('black', "total occurences of sleep stage overlap\n\n")
end

fprintf("Saved all patient data to:")
cprintf("magenta", " \t%s\n", saveDir)
