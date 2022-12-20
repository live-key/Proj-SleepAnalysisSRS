% Calculate the start times for a given set of metrics (apneas, sleep stages) 
% Author: Joe Byrne
% --------------------------------------------------------------------%
% Input:  pred      -> model predicted data
%         act       -> actual data
% Output: mcc       -> Matthews Correlation Coefficient

function mcc = MCC(pred, act)
    pred_pos = pred == 1; 
    pred_neg = pred == 0;
    act_pos  =  act == 1;
    act_neg  =  act == 0;

    tp = sum(pred_pos.*act_pos);
    tn = sum(pred_neg.*act_neg);
    fp = sum(pred_pos.*act_neg);
    fn = sum(pred_neg.*act_pos);

    prod = (tp+fp)*(fn+tn)*(tp+fn)*(fp+tn);

    mcc = (tp*tn - fp*fn) / sqrt(prod);
end