% Get patient data and prepare epochs
% Author: Joe Byrne

clear, clc
close all

% Vars
channel_names  = ["Ffour_Mone"  , "Fthree_Mtwo" , "Cfour_Mone" , ... 
                  "Cthree_Mtwo" , "Otwo_Mone"   , "Oone_Mtwo"   ];
timestep = load('..\Data\Database\P1\Data.mat', 'TimeStep');


for ii = 1:length(channel_names)
    % Get data
    eeg = load('..\Data\Database\P2\Data.mat', channel_names(ii)).(channel_names(ii))(:, 1:3300);

    for jj = 0:1100-1
        epoch = eeg(:, jj*3 + 1:(jj+1)*3);
        eeg_epochs{ii, jj+1} = reshape(epoch, [1, size(epoch,1)*size(epoch,2)]);;
    end
    
end

