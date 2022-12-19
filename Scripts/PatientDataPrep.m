% Get multiple patients' data
% Author: Joe Byrne

clear, clc
close all

% Setup parameters for data prep 
num_patients = 2;
for ii = 1:num_patients
    patients(ii) = sprintf("P%s", num2str(ii));
end

start_times = { datetime(2020, 1, 8, 20, 35, 52); 
                datetime(2020, 1, 9, 20, 29, 48);  };

% Get patient data in feature vector
for ii = 1:num_patients
    PatientData(patients(ii), start_times{ii});
end


