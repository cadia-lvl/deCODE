function measure_f0_variability4(varargin)
% Usage: measure_f0_variability(..., 'options', ...)
%
% Options:
%
%   '--audio', 'FILE'      Name of the input audio file.
%
%   '--gcif', 'FILE'       Name of an input file containing the glottal closure
%                          instants detected from the audio file.
%
%   '--vari', 'FILE'       Name of the output .mat file, where 5 variability
%                          property vectors will be saved along with a time-
%                          position vector and a signal intensity vector. The
%                          analysis hop size will be 100 ms.
%

% Intensity estimation in place of voice detection. Average
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

[signal, rate] = wavread(audio);
duration = size(signal, 1) / rate;
closest_gci = zeros(1+round( duration * 20e3 ),1);
load(gcif, 'gci')
number_gcis = length(gci);
closest_gci(1:mean( gci(1:2) )) = 1;
for i1 = 2:number_gcis-1,
  closest_gci( ceil(mean(gci(i1-1:i1))) : mean(gci(i1:i1+1)) ) = i1;
end
closest_gci(ceil(mean( gci(end-1:end) )):end) = number_gcis;

time_position = 0:0.1:duration;
number_positions = length(time_position);
average_power = zeros(number_positions, 1);
for i1 = 1:number_positions,
  sample = 1+round( time_position(i1) * 20e3 );
  if closest_gci(sample) >= 9 && closest_gci(sample) <= number_gcis-9
    frame = gci( closest_gci(sample) +(-8:9)); % 18 GCIs
    frame_start = (frame(1)-1) / 20e3; % in seconds
    frame_end = (frame(end)-1) / 20e3;
    frame_signal = signal(1+round(frame_start*rate):1+round(frame_end*rate));
    average_power(i1) = mean(frame_signal.^2);
  end
end
intensity = medfilt1(average_power, 5);

magnitude = zeros(number_positions, 1);
centroid  = zeros(number_positions, 1);
spread    = zeros(number_positions, 1);
skewness  = zeros(number_positions, 1);
kurtosis  = zeros(number_positions, 1);
for i1 = 1:number_positions,
  sample = 1+round( time_position(i1) * 20e3 );
  if closest_gci(sample) >= 9 && closest_gci(sample) <= number_gcis-9
    frame = gci( closest_gci(sample) +(-8:9)); % 18 GCIs
    if frame(end) - frame(1) < 17*0.02*20e3 % voiced
      [magnitude(i1), centroid(i1), spread(i1), skewness(i1), kurtosis(i1)] ...
          = frame_f0_variability4(frame);
    end
  end
end

save(vari, 'magnitude', 'centroid', 'spread', 'skewness', 'kurtosis', ...
     'time_position', 'intensity')
