% Calculate the average power for each of the five frequency bands 
% Author: Joe Byrne

function p_vector = CalcPower(sig_, dc_)    
    dc_ = dc_^2;
    
    Fsig_ = fft(sig_) / length(sig_);
    aFsig_ = abs(Fsig_); 
   
    p_spectrum = aFsig_.^2; 
    p_spectrum = 2*p_spectrum(1:floor(length(Fsig_)/2));
    p_spectrum(1) = p_spectrum(1)/2;

    p_spectrum = 10*log10(p_spectrum / dc_);
    
    %----------------delta----theta----alpha------beta-------gamma----%
    band_ranges = { 1:4, 4:8, 8:12, 12:30, 30:length(p_spectrum) }; 

    for ii = 1:size(band_ranges, 2)
        p_vector(ii) = mean(p_spectrum(band_ranges{ii}));
    end
end

