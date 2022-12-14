% Get patient data; prepare epochs, feature list, and labels
% Author: Joe Byrne

clear, clc
close all

patient = "P1";
dataDir = sprintf("..\\Data\\Database\\%s\\Data.mat", patient);

%% Data Preperation

% Field names for struct extraction
channel_names  = ["Ffour_Mone" , "Fthree_Mtwo" , "Cfour_Mone" , "Cthree_Mtwo" , "Otwo_Mone" , "Oone_Mtwo"];
timestep = load(dataDir, 'TimeStep');

% Remove unwanted data at end of signal
CLIP = 3300;

for ii = 1:length(channel_names)
    % Get data
    eeg = load(dataDir, channel_names(ii)).(channel_names(ii))(:, 1:CLIP);
    
    % FFT to retrieve overall DC gain
    EEG = reshape(eeg, [1, size(eeg,1)*size(eeg,2)]);
    eegFFT = fft(EEG) / length(EEG);
    eegFFT = abs(eegFFT);
    dc(ii) = eegFFT(1);

    % Divide all six channels of data into 30s epochs
    epoch_length = 30;
    for jj = 0:CLIP/(0.1 * epoch_length) - 1
        % Take 3 x 10s long columns and reshape 
        epoch = eeg(:, jj*3 + 1:(jj+1)*3);
        eeg_epochs{ii, jj+1} = reshape(epoch, [1, size(epoch,1)*size(epoch,2)]);
    end
end

%% Feature Extraction

% Feature Vector:
% [ delta,  theta,  alpha, beta,  gamma ]

% Calculate the power associated with each frequency band, in each channel,
% for each 30s epoch of data
for channel = 1:size(eeg_epochs, 1)
    for epoch = 1:size(eeg_epochs, 2)
        power = CalcPower(eeg_epochs{channel, epoch}, dc(channel));
        feature_vector{channel, epoch} = power;
    end
end

%% Label Extraction
apnea_annotations  = ["apnea_central", "apnea_mixed", ...
    "apnea_obstructive", "hypopnea"];

% Analysis start time => 8:50:52 pm
analysis_start = 20*3600 + 50*60 + 52;

% Get apnea occurrences
all_apnea_times = [];
for ii = 0:length(apnea_annotations)-1
    % Get apnea annotations
    apnea_type = load(dataDir, "Annotations").("Annotations").(apnea_annotations(ii+1));
    for jj = 1:size(apnea_type,1)
          % Convert 18-char timestamps to readable time
          char18_timestamp_start  = int64(str2num(apnea_type{jj, 1}));
          dt = System.DateTime(char18_timestamp_start);
          disp(dt.ToString)

          % Convert apnea time to seconds
          apnea_times(jj) = 3600*dt.Hour + 60*dt.Minute + dt.Second - analysis_start;
          if dt.Hour < 12 
             apnea_times(jj) = apnea_times(jj) + 24*3600;
          end
          % Account for clipped data
          apnea_times(jj) = min(apnea_times(jj), 10*CLIP);

    end
    % Append to all apnea times store
    all_apnea_times = [all_apnea_times, apnea_times];
end

labels = zeros(length(eeg_epochs),1);
for ii = 1:length(all_apnea_times)
    apnea_start = floor(all_apnea_times(ii)/epoch_length);
    labels(apnea_start) = 1;
    if length(labels) > length(eeg_epochs)
        disp("ovf")
    end
end

%% Tabulation
tabulated_data = cell2table(feature_vector',  "VariableNames", ...
    ["F4-M1","F3-M2","C4-M1","C3-M2","O2-M1","O1-M2"]);
tabulated_data.ApneaStart = labels;

saveDir = sprintf("..\\Data\\Database\\%s\\MLDataTable.mat", patient);
save(saveDir, "tabulated_data", "-mat");
