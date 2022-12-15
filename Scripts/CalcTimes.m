% Calculate the start times for a given set of metrics (apneas, sleep stages) 
% Author: Joe Byrne
% --------------------------------------------------------------------%
% Input:  anno_names    -> array of strings containing annotation names
%         start_time    -> analysis start time
%         patient       -> string, patient label
% Output: all_times     -> all start times of occurences

function all_times = CalcTimes(anno_names, start_time, patient, CLIP)
    dataDir = sprintf("..\\Data\\Database\\%s\\Data.mat", patient);

    % Get event occurrences
    all_times = [];
    for ii = 1:length(anno_names)
        % Get annotations
        type = load(dataDir, "Annotations").("Annotations").(anno_names(ii));
        for jj = 1:size(type,1)
            % Convert 18-char timestamp to readable time
            char18_timestamp_start  = int64(str2num(type{jj, 1}));
            dt = System.DateTime(char18_timestamp_start);
            dt = datetime(dt.Year, dt.Month, dt.Day, dt.Hour, dt.Minute, dt.Second);
            
            % Convert time difference to seconds
            times(1,jj) = seconds(dt - start_time);
            
            % Account for clipped data
            times(1,jj) = min(times(1,jj), 10*CLIP);

            % Input type
            times(2, jj) = find(anno_names == strrep(type{1, 3}, "-", "_"));
        end
        % Append to all times store
        all_times = [all_times, times];
    end
end