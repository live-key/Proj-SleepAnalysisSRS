% Retrieve and display EEG data from a patient
% Author: Joe Byrne

clear, clc
close all


% Vars
channel_names  = ["Ffour_Mone"  , "Fthree_Mtwo" , "Cfour_Mone" , ... 
                  "Cthree_Mtwo" , "Otwo_Mone"   , "Oone_Mtwo"   ];
channel_labels = ["F4-M1" , "F3-M2" , "C4-M1" , ...
                  "C3-M2" , "O2-M1" , "O1-M2"  ];
timestep = load('..\Data\Database\P2\Data.mat', 'TimeStep');

% Fig setup
figure('units','normalized','outerposition',[0 0 1 1])
tiledlayout(3,2);

for ii = 1:length(channel_names)
    % Get data
    eeg = load('..\Data\Database\P2\Data.mat', channel_names(ii)).(channel_names(ii));
    EEG{ii} = reshape(eeg, [1, size(eeg,1)*size(eeg,2)]);
    TIME = linspace(0, size(timestep,2)*10, size(EEG{ii},2)) / 3600;
    
    % Plot data
    nexttile
    plot(TIME, EEG{ii})
    title(sprintf("EEG: Channel %s", channel_labels(ii)))
    ylabel('EKG Reading (\muV)')
    if ii > length(channel_names) - 2
        xlabel('Time (h)')
    end
end