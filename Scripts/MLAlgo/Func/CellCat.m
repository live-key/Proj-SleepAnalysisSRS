% Concatenate cell contents 
% Author: Joe Byrne
% --------------------------------------------------------------------%
% Input:  data      -> Cell array of data
% Output: cat       -> Concatenated cell data

function cat = CellCat(data)
    cat = [];
    for ii = 1:size(data,1)
        cat = [cat; data{ii}];
    end
end
