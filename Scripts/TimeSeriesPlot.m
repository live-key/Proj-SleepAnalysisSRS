% Retrieve and display EEG data from a patient
% Author: Joe Byrne

clear, clc
close all

%% Setup
% Target directory
patient = "P1";
dataDir = sprintf("..\\Data\\Database\\%s\\Data.mat", patient);

% Target channels
channel_names  = ["Ffour_Mone"  , "Fthree_Mtwo" , "Cfour_Mone" , ... 
                  "Cthree_Mtwo" , "Otwo_Mone"   , "Oone_Mtwo"   ];
channel_labels = ["F4-M1" , "F3-M2" , "C4-M1" , ...
                  "C3-M2" , "O2-M1" , "O1-M2"  ];

% Get timestep for timeseries status
timestep = load(dataDir, 'TimeStep');

% Fig setup
figure('units','normalized','outerposition',[0 0 1 1])
tiledlayout(3,2);

%% Execute
for ii = 1:length(channel_names)
    % Get data
    eeg = load(dataDir, channel_names(ii)).(channel_names(ii));
    EEG{ii} = reshape(eeg, [1, size(eeg,1)*size(eeg,2)]);
    
    % remove capped data 
    lim = 0.003;
    capped = (EEG{ii}<=-lim)+(EEG{ii}>=lim);
    capped_ind = find(capped==1);
    EEG{ii}(capped_ind) = 0;

    TIME = linspace(0, size(timestep,2)*10, size(EEG{ii},2)) / 3600;
    
    % Plot data
    nexttile
    plot(TIME, EEG{ii})
    title(sprintf("EEG: Channel %s", channel_labels(ii)))
    ylabel('EKG Reading (\muV)')
    if ii > length(channel_names) - 2
        xlabel('Time (h)')
    end
    ylim([-0.004, 0.004])
end