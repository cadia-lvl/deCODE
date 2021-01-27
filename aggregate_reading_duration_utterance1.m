function reading_duration = aggregate_reading_duration_utterance1(varargin)
% Usage: aggregate_reading_duration_utterance(..., 'options', ...)
%
% Options:
%
%   '--audio', 'FILE'           Input audio file.
%
%   '--out', 'FILE'             Name of the output file.
%

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
        disp('aggregate_reading_duration_utterance.m: input file name missing')
      end
    case '--out'
      ind_arg = ind_arg + 1;
      if ind_arg <= nargin
        out = varargin{ind_arg};
      else
        disp('aggregate_reading_duration_utterance.m: output file name missing')
      end
    otherwise
      error(['aggregate_reading_duration.m: unrecognized argument ' ...
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

[signal, rate] = wavread(audio);
reading_duration = round( size(signal, 1) / rate *1000); % in milliseconds
  
%save(out, 'reading_duration')
