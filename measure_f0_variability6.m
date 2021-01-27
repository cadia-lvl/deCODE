function measure_f0_variability6(varargin)
% Usage: measure_f0_variability(..., 'options', ...)
%
% Options:
%
%   '--audio', 'FILE'      Name of the input audio file.
%
%   '--gcif', 'FILE'       Name of an input file containing the glottal closure
%                          instants detected from the audio file.
%
%   '--vari', 'FILE'       Name of the output .mat file, where a variability
%                          (magnitude) value will be saved.
%

% Bugs fixed for short audio and for interpolation.
% Michal's measure. Intensity estimation in place of voice detection. Average
% power median-filtered. Selecting reliable voiced frames by average power.

audio = '';
gcif = '';
vari = '';
ind_arg = 1;
while ind_arg <= nargin,
  switch varargin{ind_arg}
    case '--audio'
      ind_arg = ind_arg + 1;
      if ind_arg <= nargin
        audio = varargin{ind_arg};
      else
        disp('measure_f0_variability.m: audio file name missing')
      end
    case '--gcif'
      ind_arg = ind_arg + 1;
      if ind_arg <= nargin
        gcif = varargin{ind_arg};
      else
        disp('measure_f0_variability.m: GCI file name missing')
      end
    case '--vari'
      ind_arg = ind_arg + 1;
      if ind_arg <= nargin
        vari = varargin{ind_arg};
      else
        disp('measure_f0_variability.m: output file name missing')
      end
    otherwise
      error(['measure_f0_variability.m: unrecognized argument ' ...
             varargin{ind_arg}])
  end
  ind_arg = ind_arg + 1;
end
if isempty(audio)
  error('Audio file name must be specified!')
end
if isempty(gcif)
  error('Name of the GCI file must be specified!')
end
if isempty(vari)
  error('Output file name must be specified!')
end

pkg load signal
load(gcif, 'gci')

%% interpolate with fs=2e3, need to remove outliers 1st
% still a problem of VAD
spline_fs = 2e3;
mid = 1+round( (length(gci)-1)*0.5 );
span = round( (length(gci)-1)*0.4 );
t = gci(mid-span+1:mid+span);
dt = MAD_outliers(diff(gci(mid-span:mid+span)));
xi = t(1):20e3/spline_fs:t(end);
interpolation = interp1(t, dt, xi, 'spline');
number_samples = length(interpolation);
if number_samples < 13
  oa = interpolation;
  interpolation = zeros(1, 13);
  interpolation(1:number_samples) = oa;
  number_samples = 13;
end

%% Variability computation
% Assumes that the singal is composed of "true" f0 countours (LowFreq)
% and some variation (HighFreq) - Ws set to 6Hz = 150ms a standard length of 
% vowel a
Ws = 6 / (spline_fs/2);
[bh, ah] = cheby2(4, 40, Ws, 'high');
[bl, al] = cheby2(4, 40, Ws, 'low');
sigl = filtfilt(bl, al, interpolation);
sigh = filtfilt(bh, ah, interpolation);
magnitude = sum(sigh.*sigh) / sum(sigl.*sigl) * 100;

save(vari, 'magnitude')
