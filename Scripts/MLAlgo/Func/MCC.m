% Calculate the start times for a given set of metrics (apneas, sleep stages) 
% Author: Joe Byrne
% --------------------------------------------------------------------%
% Input:  data      -> Sub-sample data to be split
% Output: train     -> Train data
%         test      -> Test data

function [train, test, test_ind] = SubSampleSplit(data)
    cv = cvpartition(size(data, 1), 'HoldOut', 0.2);
    test_ind = cv.test;
    train = data(~test_ind, :);
    test  = data(test_ind, :);
end