% Calculate the average power for each of the five frequency bands 
% Author: Joe Byrne
% -------------------------------------------------------------------- %
% Input:  sig_      -> timeseries array containing wave data segment
% Output: p_vector  -> containing all mean power values of freq bands

function p_vector = TCalcPower(sig_)
    % Get periodogram
    fs = 200;
    N = length(sig_);
    [pxx, ff] = periodogram(sig_,rectwin(N),N,fs);
    pxx = pow2db(pxx);
    
    % Define bands: delta, theta, alpha, beta, gamma
    band_ranges = [1, 4; 4, 8; 8, 12; 
                    12, 30; 30, 40];
    
    % Calculate output
    for ii = 1:size(band_ranges, 1)
        val_idx = (ff > band_ranges(ii,1)) .* ...
                    ((ff < band_ranges(ii,2)));
        p_vector(ii) = mean(pxx(val_idx == 1));
    end
end

