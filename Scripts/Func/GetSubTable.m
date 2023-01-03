% Get a sub table with substring of variable names 
% Author: Joe Byrne
% --------------------------------------------------------------------%
% Input:  tab       -> table of data
%         sub_str   -> substring for search
%         contains  -> boolean, contains or not contains
% Output: sub_tab   -> sub table with substring match

function sub_tab = GetSubTable(tab, sub_str, contains)
    sub_str = unique(sub_str);
    hasMatch = 0;
    for ii = 1:length(sub_str)
        hasMatch = hasMatch + ~cellfun('isempty', regexp(tab.Properties.VariableNames, sub_str(ii), 'once'));
    end
    if ~contains
        hasMatch = ~hasMatch;
    end
    sub_tab = tab(:, tab.Properties.VariableNames(find(hasMatch == true)));
end