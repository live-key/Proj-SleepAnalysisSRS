% Prepare data for a given patient from PSG
% Author: Joe Byrne
% -------------------------------------------------------------------- %
% Input:  patient   -> patient label for data
%         start_dt  -> datetime object of start time of analysis

function PatientData(patient, start_dt, verbose)
    %% Data Preperation
    prefix = "F:";
    dataDir = sprintf("%s/Database/%s/Data.mat", prefix, patient);
    
    if verbose
    cprintf("*black", "Patient Number %s:\n\n", extractAfter(patient, "P"))
    disp("Preparing Data...")
    end
    
    % Field names for struct extraction
    channel_names  = ["Ffour_Mone" , "Fthree_Mtwo" , "Cfour_Mone" , "Cthree_Mtwo" , "Otwo_Mone" , "Oone_Mtwo"];
    
    % Remove unwanted data at end of signal
    CLIP = 3300;
    
    if verbose; disp("Calculating PSD..."); end
    for ii = 1:length(channel_names)
         % Divide all six channels of data into 30s epochs
        epoch_length = 30;

        % Get data
        eeg = load(dataDir, channel_names(ii)).(channel_names(ii));

        % Clip data to size
        CLIP = 30*floor(size(eeg,2)/epoch_length);
        eeg = eeg(:,1:CLIP);
            

        for jj = 0:CLIP/(0.1 * epoch_length) - 1
            % Take 3 x 10s long columns and reshape 
            epoch = eeg(:, jj*3 + 1:(jj+1)*3);
            eeg_epochs{ii, jj+1} = reshape(epoch, [1, size(epoch,1)*size(epoch,2)]);
        end
    end
    
    %% Feature Extraction
    
    if verbose; disp("Setting up features..."); end
    
    % Feature Vector:
    % [ delta,  theta,  alpha, beta,  gamma, n1, n2, n3, rem, wake ]
    
    % Calculate the power associated with each frequency band, in each channel,
    % for each 30s epoch of data
    for channel = 1:size(eeg_epochs, 1)
        for epoch = 1:size(eeg_epochs, 2)
            power = TCalcPower(eeg_epochs{channel, epoch});
            feature_vector{channel, epoch} = power;
        end
    end
    
    stage_annotations = ["sleep_n1", "sleep_n2", "sleep_n3", ...
        "sleep_rem", "sleep_wake"];
    
    all_stage_times = CalcTimes(stage_annotations, start_dt, dataDir, CLIP);
    stages = OneHot(all_stage_times, length(eeg_epochs), epoch_length);
    
    %% Label Extraction
    
    if verbose; disp("Getting labels..."); end
    
    apnea_annotations  = ["apnea_central", "apnea_mixed", ...
        "apnea_obstructive", "hypopnea"];
    
    all_apnea_times = CalcTimes(apnea_annotations, start_dt, dataDir, CLIP);
    % labels = OneHot(all_apnea_times, length(eeg_epochs), epoch_length); 
    
    % Apply a 1 when epoch time matches apnea start time
    labels = zeros(length(eeg_epochs),1);
    for ii = 1:size(all_apnea_times,2)
        apnea_start = ceil(all_apnea_times(1,ii)/epoch_length);
        labels(apnea_start) = 1;
    end
    
    %% Tabulation
    
    if verbose; disp("Tabulating and exporting data..."); end
    
    % Tabulate power data
    tabulated_data = cell2table(feature_vector',  "VariableNames", ...
        ["F4-M1","F3-M2","C4-M1","C3-M2","O2-M1","O1-M2"]);
    tabulated_data.STAGE = stages;
    tabulated_data.LABEL = labels;
    tabulated_data = splitvars(tabulated_data);
    
    % Remove INF, NAN, and ZERO values (flat signal)
    tabulated_data = tabulated_data(isfinite(tabulated_data.("F4-M1_1")), :);
    
    % Save data to new file in patient directory
    
    saveDir = sprintf("%s/Database/%s/MLDataTable.mat", prefix, patient);
    save(saveDir, "tabulated_data", "-mat");
    
    if verbose
    fprintf("\nExport successful!\n")
    fprintf("Saved data to:");
    cprintf("magenta", " \t%s\n", saveDir)
    fprintf("\n*************************\n\n")
    end
end