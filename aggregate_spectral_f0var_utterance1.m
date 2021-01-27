function aggregate_spectral_f0var_utterance1(varargin)
% Usage: aggregate_spectral_f0var_utterance(..., 'options', ...)
%
% Options:
%
%   '--f0var', 'FILE'           Input file containing spectral F0 variability
%                               measurements.
%
%   '--out', 'FILE'             Name of the output file.
%
%   '--phnm', 'FILE'            Reading alignment.
%

f0var = '';
out = '';
phnm = '';
ind_arg = 1;
while ind_arg <= nargin,
  switch varargin{ind_arg}
    case '--f0var'
      ind_arg = ind_arg + 1;
      if ind_arg <= nargin
        f0var = varargin{ind_arg};
      else
        disp('aggregate_spectral_f0var_utterance.m: input file name missing')
      end
    case '--out'
      ind_arg = ind_arg + 1;
      if ind_arg <= nargin
        out = varargin{ind_arg};
      else
        disp('aggregate_spectral_f0var_utterance.m: output file name missing')
      end
    case '--phnm'
      ind_arg = ind_arg + 1;
      if ind_arg <= nargin
        phnm = varargin{ind_arg};
      else
        disp('aggregate_spectral_f0var_utterance.m: reading alignment missing')
      end
    otherwise
      error(['aggregate_spectral_f0var_utterance.m: unrecognized argument ' ...
             varargin{ind_arg}])
  end
  ind_arg = ind_arg + 1;
end
if isempty(f0var)
  error('Input file name must be specified!')
end
if isempty(out)
  error('Output file name must be specified!')
end

[magnitude, centroid, spread, skewness, kurtosis] = ...
    evaluate_parameters(f0var, phnm);

save(out, 'magnitude', 'centroid', 'spread', 'skewness', 'kurtosis')

function [magnitude, centroid, spread, skewness, kurtosis] = ...
    evaluate_parameters(f0var, alignment)

magnitude_vector = [];
centroid_vector = [];
spread_vector = [];
skewness_vector = [];
kurtosis_vector = [];

[oa1, oa2, oa3, oa4, oa5] = ...
    read_spectral_f0var1(f0var, alignment);
magnitude_vector = [magnitude_vector;oa1];
centroid_vector  = [centroid_vector;oa2];
spread_vector    = [spread_vector;oa3];
skewness_vector  = [skewness_vector;oa4];
kurtosis_vector  = [kurtosis_vector;oa5];

if isempty(magnitude_vector)
  magnitude = nan;
  centroid  = nan;
  spread    = nan;
  skewness  = nan;
  kurtosis  = nan;
else
  magnitude = median(magnitude_vector);
  centroid  = median(centroid_vector);
  spread    = median(spread_vector);
  skewness  = median(skewness_vector);
  kurtosis  = median(kurtosis_vector);
end
