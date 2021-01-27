function aggregate_formant_utterance1(varargin)
% Usage: aggregate_formant_utterance(..., 'options', ...)
%
% Options:
%
%   '--formant', 'FILE'         Input file containing formant frequency
%                               estimates.
%
%   '--out', 'FILE'             Name of the output file.
%

formant = '';
out = '';
ind_arg = 1;
while ind_arg <= nargin,
  switch varargin{ind_arg}
    case '--formant'
      ind_arg = ind_arg + 1;
      if ind_arg <= nargin
        formant = varargin{ind_arg};
      else
        disp('aggregate_formant_utterance.m: input file name missing')
      end
    case '--out'
      ind_arg = ind_arg + 1;
      if ind_arg <= nargin
        out = varargin{ind_arg};
      else
        disp('aggregate_formant_utterance.m: output file name missing')
      end
    otherwise
      error(['aggregate_formant_utterance.m: unrecognized argument ' ...
             varargin{ind_arg}])
  end
  ind_arg = ind_arg + 1;
end
if isempty(formant)
  error('Input file name must be specified!')
end
if isempty(out)
  error('Output file name must be specified!')
end

[formant_median, formant_mean, formant_standard_deviation, duration_vowel] = ...
    evaluate_parameters(formant);

save(out, 'formant_median', 'formant_mean', 'formant_standard_deviation', ...
     'duration_vowel')

function [median_value, mean_value, standard_deviation, vowel_duration] = ...
    evaluate_parameters(formant)

f1 = [];
f2 = [];
f3 = [];
f4 = [];
duration = [];

[oa1, oa2, oa3, oa4, oa5] = ...
    octread_formant_frequencies5(formant);
f1 = [f1;oa1];
f2 = [f2;oa2];
f3 = [f3;oa3];
f4 = [f4;oa4];
duration = [duration;oa5];

median_value = repmat(nan, 4, 1);
mean_value = repmat(nan, 4, 1);
standard_deviation = repmat(nan, 4, 1);
vowel_duration = nan;
if ~isempty(f1)
  median_value(1) = median(f1);
  median_value(2) = median(f2);
  median_value(3) = median(f3);
  median_value(4) = median(f4);

  mean_value(1) = mean(f1);
  mean_value(2) = mean(f2);
  mean_value(3) = mean(f3);
  mean_value(4) = mean(f4);

  standard_deviation(1) = std(f1);
  standard_deviation(2) = std(f2);
  standard_deviation(3) = std(f3);
  standard_deviation(4) = std(f4);

  vowel_duration = mean(duration);
end
