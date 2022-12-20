% One-hot-encode provided data 
% Author: Joe Byrne
% --------------------------------------------------------------------%
% Input:  input_data    -> 2 x N array containing time data and indexing
% Output: one_hot       -> One-hot-encoded output

function one_hot = OneHot(input_data, epoch_amount, epoch_length)
    one_hot = zeros(epoch_amount, 1);
    for ii = 1:size(input_data,2)
        stage_start = floor(input_data(1,ii)/epoch_length);
        one_hot(stage_start, input_data(2,ii)) = 1;
    end
end