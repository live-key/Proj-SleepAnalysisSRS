% Get patient data; prepare epochs and feature list
% Author: Joe Byrne

clear, clc
close all

% Feature Vector:
% [ delta,  theta,  alpha, beta,  gamma ]

% Field names for struct extraction
channel_names  = ["Ffour_Mone" , "Fthree_Mtwo" , "Cfour_Mone" , "Cthree_Mtwo" , "Otwo_Mone" , "Oone_Mtwo"];
timestep = load('..\Data\Database\P1\Data.mat', 'TimeStep');

for ii = 1:length(channel_names)
    % Get data
    eeg = load('..\Data\Database\P2\Data.mat', channel_names(ii)).(channel_names(ii))(:, 1:3300);
    
    % FFT to retrieve overall DC gain
    EEG = reshape(eeg, [1, size(eeg,1)*size(eeg,2)]);
    eegFFT = fft(EEG) / length(EEG);
    eegFFT = abs(eegFFT);
    dc(ii) = eegFFT(1);

    % Divide all six channels of data into 30s epochs
    epoch_length = 30;
    for jj = 0:3300/(0.1 * epoch_length) - 1
        % Take 3 x 10s long columns and reshape 
        epoch = eeg(:, jj*3 + 1:(jj+1)*3);
        eeg_epochs{ii, jj+1} = reshape(epoch, [1, size(epoch,1)*size(epoch,2)]);
    end
end


for channel = 1:size(eeg_epochs, 1)
    for epoch = 1:size(eeg_epochs, 2)
        power = CalcPower(eeg_epochs{channel, epoch}, dc(channel));
        feature_vector{channel, epoch} = power;
    end
end



