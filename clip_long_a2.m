function clip_long_a2(varargin)
% Usage: clip_long_a('audio')
%
% Options:
%
%   '--audio', 'FILE'      Name of the input audio file.
%
%   '--out', 'FILE'        Name of the output audio file.
%

% Using an output file name specified by the user.

audio = '';
out = '';
ind_arg = 1;
while ind_arg <= nargin,
  switch varargin{ind_arg}
    case '--audio'
      ind_arg = ind_arg + 1;
      if ind_arg <= nargin
        audio = varargin{ind_arg};
      else
        disp('clip_long_a.m: input file name missing')
      end
    case '--out'
      ind_arg = ind_arg + 1;
      if ind_arg <= nargin
        out = varargin{ind_arg};
      else
        disp('clip_long_a.m: output file name missing')
      end
    otherwise
      error(['clip_long_a.m: unrecognized argument ' ...
             varargin{ind_arg}])
  end
  ind_arg = ind_arg + 1;
end
if isempty(audio)
  error('Input file name must be specified!')
end
if isempty(out)
  error('Output file name must be specified!')
end

pkg load signal

sampling_frequency = 20e3;

[oa1, oa2] = wavread(audio);
file = resample(oa1, sampling_frequency, oa2);
number_samples = length(file);

first_sample = 1:320:number_samples-639;
number_frames = length(first_sample);
average_power = zeros(number_frames, 1);
for i1 = 1:number_frames,
  oa = first_sample(i1) + (0:639);
  frame = file(oa);
  average_power(i1) = mean(frame.^2);
end
intensity = medfilt1(average_power, 21);
normalized_intensity = intensity / max(intensity);
which_intense = find(normalized_intensity > 1/3);
first_selected = which_intense(1);
last_selected = which_intense(end);
clip = file(first_sample(first_selected): ...
            first_sample(last_selected)+639);
wavwrite(clip, sampling_frequency, out)
