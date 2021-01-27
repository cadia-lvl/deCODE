% Output parameters calculated; analyzing a fixed number
% of cycles. Normalized by median period; power spectrum. 2-kHz interpolation.

function [magnitude, centroid, spread, skewness, kurtosis] = ...
    frame_f0_variability4(gci)

number_gcis = length(gci);
period = diff(gci);
normalized_period = period / median(period);
number_samples = (number_gcis-2) * 8;
step_size = (gci(end)-gci(2)) / number_samples;
instantaneous_period = spline(gci(2:end), normalized_period, ...
                              gci(2) : step_size : ...
                              gci(2)+(number_samples-1)*step_size);
zero_mean_period = instantaneous_period - mean(instantaneous_period);
windowed_period = zero_mean_period.' .* hamming(number_samples);
oa = abs(fft(windowed_period)) / number_samples;
power_spectrum_period = oa(2:number_samples/2+1).^2; % DC bin excluded

magnitude = sum(power_spectrum_period);
distribution = power_spectrum_period / magnitude;
frequency = ( 1:number_samples/2 ).';
centroid              = sum( frequency               .* distribution );
mean_square           = sum( frequency.^2            .* distribution );
mean_cubic            = sum( frequency.^3            .* distribution );
fourth_central_moment = sum( (frequency-centroid).^4 .* distribution );
spread = sqrt( mean_square - centroid.^2 );
skewness = ( mean_cubic - 3*centroid*spread.^2 - centroid.^3 )/spread.^3;
kurtosis = fourth_central_moment / spread.^4;

if ~nargout
  plot(power_spectrum_period)
  xlabel('DFT Frequency Index')
  ylabel('Linear-Scale Magnitude')
end
