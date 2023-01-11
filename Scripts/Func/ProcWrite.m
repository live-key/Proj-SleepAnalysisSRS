% Process and write excel data
% Author: Joe Byrne
% --------------------------------------------------------------------%
% Input:  data      -> data to write
%         file      -> file to write in 
%         sheet     -> sheet to write in 
%         cell      -> cell to start write at

function ProcWrite(data, file, sheet, cell)
    data_c = num2cell(data);
    data_c(isnan(data)) = {'NaN'};
    writecell(data_c, file, 'Sheet', sheet, 'Range', cell, 'AutoFitWidth', false);
end