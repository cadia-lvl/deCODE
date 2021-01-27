% Handling exceptionally short cycles and the zero estimate. Using
% GCIs derived from true glottal areas; not extracting the closed quotient.

function [mfdr, pa, naq, h1h2, hrf] = extractVoiceFeatures(u, fs, gci)

%EXTRACTVOICEFEATURES extracts voice features from the glottal flow
%derivative  [mfdr, cq, pa, naq] = extractVoiceFeatures(u, fs, gci)
%
%  Inputs:  u        is the glottal flow in [cm^3/s]
%           fs       is the sampling frequency in Hz
%           gci      is the glottal closure instants indices (samples) of
%                    length Ng
%
% Outputs: 
% Features defined in Patel 2011 that are derived from glottal flow
% of length Ng
%
% MFDR  - Maximum Flow Declination Rate  [l/s^2]
% CQ    - Closed Quotient  [unitless]
% PA    - Pulse Amplitude  [cm^3/s]
% NAQ   - Normalized Amplitude Quotient [unitless]
% H1-H2  - Level difference between first and second harmonics
%          (computed from the long term average spectrum (LTAS))
% HRF  (harmonic richness factor)

uu=[diff(u); 0]*fs;
opThres = 0.05;

number_cycles = length(gci) - 1;
mfdr = zeros(number_cycles, 1);
pa = zeros(number_cycles, 1);
cq = zeros(number_cycles, 1);
naq = zeros(number_cycles, 1);
h1h2 = zeros(number_cycles, 1);
hrf = zeros(number_cycles, 1);

for ig = 1:number_cycles,
  T = gci(ig+1) - gci(ig);
  nn = (0:T-1) + gci(ig);  
  
  uuseg=uu(nn);
  useg=u(nn);
  
  % Maximum flow declination rate
  dpeak = -min(uuseg);  % flow derivative in cm^3/s^2

  % Maximum flow
  fac = max(useg) - min(useg);      % flow in cm^3/s
  
  % Pitch period 
  Ttime=T/fs;           % in seconds
  
  % Determining the duration of the open phase from the flow
  usegShift = useg-median(useg);

  chsign=diff(medfilt1(double(usegShift>opThres*max(usegShift)),7));  %Threshold the useg, median filter and find $
  pch = find(chsign==1);    % Find where it goes to one (potential start of open phase)
  nch = find(chsign==-1);   %
  for ii = 1:length(pch)  % This way we start looking at "open segments" where the first "opening" is
      nchIx = find(pch(ii)<nch);
      if ~any(nchIx)  % there is no closing at the end, so assume that it is the end of the segment
          segLen(ii) = length(useg) - pch(ii);
      else
          segLen(ii) = nch(nchIx(1)) - pch(ii);
      end;
  end;

  mfdr(ig) = dpeak/1000;   % in liters per second squared
  naq(ig) = fac/(dpeak*Ttime);  % unit check: cm^3/s / (cm^3/s^2 * s) = unitless
  pa(ig) = fac;
  f0 = 1/Ttime;
  if exist("varname","segLen")
     cq(ig) = 1 - max(segLen)/T;
  end
  
  % Spectral parameters
  oa = abs(fft(useg)) / T;
  number_partials = floor(3000/f0);
  if number_partials > 1
    partial_amplitudes = oa(2:number_partials+1);
    amplitudes_db = 20*log10( partial_amplitudes / partial_amplitudes(1) );
    h1h2(ig) = -amplitudes_db(2);
    hrf(ig) = 10*log10(sum(10.^( amplitudes_db(2:end)/10 )));
  else
    h1h2(ig) = 0;
    hrf(ig) = 0;
  end

# Some postprocess
mfdr = mfdr(~isnan(mfdr(:)));
pa = pa(~isnan(pa(:)));
naq = naq(~isnan(naq(:)));
cq = cq(~isnan(cq(:)));
h1h2 = h1h2(~isnan(h1h2(:)));
hrf = hrf(~isnan(hrf(:)));

end
