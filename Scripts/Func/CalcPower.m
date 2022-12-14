% Calculate the average power for each of the five frequency bands 
% Author: Joe Byrne
% --------------------------------------------------------------------%
% Input:  sig_      -> timeseries array containing wave data segment
%         dc_       -> DC gain of overall signal
% Output: p_vector  -> containing all mean power values of freq bands

function p_vector = CalcPower(sig_, dc_)
    % Retrieve FFT and abs of FFT
    Fsig_ = fft(sig_) / length(sig_);
    aFsig_ = abs(Fsig_); 
    
    % Derive power spectrum
    p_spectrum = aFsig_.^2; 
    p_spectrum = 2*p_spectrum(1:floor(length(Fsig_)/2));
    p_spectrum(1) = p_spectrum(1)/2;

    % dc_ could be zero - iso-electric
    % Stable reference as opposed to dc_? 
    p_spectrum = pow2db(p_spectrum / dc_^2);
    
    % Define bands: delta, theta, alpha, beta, gamma
    band_ranges = { 30*1:30*4, 30*4:30*8, 30*8:30*12, ...
                    30*12:30*30, 30*30:length(p_spectrum) }; 
    
    % Calculate output
    for ii = 1:size(band_ranges, 2)
        p_vector(ii) = mean(p_spectrum(band_ranges{ii}));
    end
end

