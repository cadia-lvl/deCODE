function measure_voice_parameters(varargin)
% Usage: measure_voice_parameters(..., 'options', ...)
%
% Options:
%
%   '--audio', 'FILE'      Name of the input audio file.
%
%   '--out', 'FILE'        Name of the output text file.
%
%   '--gender', 'CHAR'     'M' or 'F'.
%
%   '--smark', 'VALUE'     Starting mark of the voice in msec.
%
%   '--emark', 'VALUE'     Ending mark of the voice in msec.
%
%   '--ctm', 'VALUE'     CTM file for segmentation.
%

audio = '';
out = '';
gender = '';
smark = [];
emark = [];
ind_arg = 1;
while ind_arg <= nargin,
  switch varargin{ind_arg}
    case '--audio'
      ind_arg = ind_arg + 1;
      if ind_arg <= nargin
        audio = varargin{ind_arg};
      else
        disp('measure_voice_parameters.m: audio file name missing')
      end
    case '--out'
      ind_arg = ind_arg + 1;
      if ind_arg <= nargin
        out = varargin{ind_arg};
      else
        disp('measure_voice_parameters.m: output file name missing')
      end
    case '--gender'
      ind_arg = ind_arg + 1;
      if ind_arg <= nargin
        gender = varargin{ind_arg};
      else
        disp('measure_voice_parameters.m: gender missing')
      end
    case '--smark'
      ind_arg = ind_arg + 1;
      if ind_arg <= nargin
        smark = str2num(varargin{ind_arg});
      else
        disp('measure_voice_parameters.m: starting mark missing')
      end
    case '--emark'
      ind_arg = ind_arg + 1;
      if ind_arg <= nargin
        emark = str2num(varargin{ind_arg});
      else
        disp('measure_voice_parameters.m: ending mark missing')
      end
    case '--ctm'
      ind_arg = ind_arg + 1;
      if ind_arg <= nargin
        ctm = varargin{ind_arg};
      else
        disp('measure_voice_parameters.m: ctm file name missing')
      end
    otherwise
      error(['measure_voice_parameters.m: unrecognized argument ' ...
             varargin{ind_arg}])
  end
  ind_arg = ind_arg + 1;
end
if isempty(audio)
  error('Audio file name must be specified!')
end
if isempty(out)
  error('Output file name must be specified!')
end
if isempty(gender)
  error('Gender must be specified!')
end
if isempty(smark)
  error('Starting mark must be specified!')
end
if isempty(emark)
  error('Ending mark must be specified!')
end

which_slash = find(audio == '/');
if isempty(which_slash)
  base_name = audio(1:end-4);
else
  base_name = audio(which_slash(end)+1:end-4);
end

if regexp(audio,'Reading','once')
  reading = 1
else
  reading = 0
end

%
pkg load signal
addpath preprocess
addpath pitch
addpath voice_source
addpath voice_source/voicebox
addpath voice_source/DYPSAGOI
addpath voice_source/Toolbox
addpath f0var
addpath common


%% voice source characteristics
disp(['Processing file ' audio])
disp('Voice source characteristics...')
source = voice_master(audio, gender, smark, emark, ctm);
orig_audio = audio;
disp('Done.')

%% preprocessing
disp('Preprocessing...')
[wave,fs] = wavread(audio);
[wave,start_ms] = preprocess(wave, fs, smark, emark);
base_name = [base_name '_preprocessed'];
audio = [base_name '.wav'];
wavwrite(wave, fs, audio)
disp('Done.')

%% formant
disp('Formant...')
formant = [base_name '_formant.pst'];
system([ 'pitch/praat --run ' ...
         'estimate_formant_frequencies2.praat ' ...
         audio ' ' formant ' ' gender ]);
formant_aggregated = [base_name '_formant_aggregated.mat'];
aggregate_formant_utterance1('--formant', formant, '--out', formant_aggregated)
load(formant_aggregated, 'formant_median', 'formant_mean', ...
     'formant_standard_deviation', 'duration_vowel')
disp('Done.')

%% ppq5 jitter
disp('ppq5 jitter...')
clip = [base_name '_clip.wav'];
clip_gci = [base_name '_clip_gci.wav'];
phnm = [base_name '_alignment.mat'];
if reading
  jitter = [base_name '_jitter.txt'];
  parse_one_ctm(ctm, phnm, start_ms)
  oa = analyze_segments_jitter(audio, phnm);
  jitter_value = median(oa);
else
  jitter = [base_name '_jitter.txt'];
  clip_long_a2('--audio', audio, '--out', clip)
  system([ 'pitch/praat --run measure_f0_variability7.praat ' ...
           clip ' > ' jitter ]);
  fid = fopen(jitter, 'rt');
  jitter_value = fscanf(fid, '%f', 'C'); fclose(fid);
  if isempty(jitter_value)
    jitter_value = nan;
  end
end
disp('Done.')

%% reading duration
disp('Reading duration...')
duration_aggregated = [base_name '_duration_aggregated.mat'];
reading_duration = aggregate_reading_duration_utterance1('--audio', audio, '--out',duration_aggregated);
disp('Done.')

%% spectral F0 variability
disp('Spectral F0 variability...')
gcif = [base_name '_gcif.mat'];
bounds = parse_vowel_ctm(ctm);
fs = 20000;

if ~isempty(bounds) && bounds(2)-bounds(1) > 0.1
  audio = orig_audio;
  [sp, fs_sp] = wavread(audio);
  bounds = round(bounds*fs_sp);
  sp = sp(bounds(1)+1:bounds(2));
else
  [sp, fs_sp] = wavread(audio);
end

sp = resample(sp, fs, fs_sp);
sp = sp * 10^6; % converting to cubic cm per sec
voicebox('dy_cpfrac', 0.35);
gci = dypsagoi2(sp, fs);
save(gcif, 'gci')
sf0var = [base_name '_sf0var.mat'];
measure_f0_variability4('--audio', audio, '--gcif', gcif, '--vari', sf0var)
sf0var_aggregated = [base_name '_sf0var_aggregated.mat'];
if reading
  aggregate_spectral_f0var_utterance1('--f0var', sf0var, '--out', ...
                                      sf0var_aggregated, '--phnm', phnm)
else
  aggregate_spectral_f0var_utterance1('--f0var', sf0var, '--out', ...
                                      sf0var_aggregated)
end
load(sf0var_aggregated, 'magnitude', 'centroid', 'spread', 'skewness', 'kurtosis' )
spectral_magnitude = magnitude;
spectral_centroid = centroid;
spectral_spread = spread;
spectral_skewness = skewness;
spectral_kurtosis = kurtosis;
disp('Done.')


%% total F0 variability
audio = [base_name '.wav'];
disp('Total F0 variability...')
tf0var = [base_name '_tf0var.mat'];

if reading
  [oa1, oa2] = analyze_segments_total(audio, gcif, phnm);
  total_magnitude = median(oa1);
else
  total_magnitude = source.jitter;
  if isnan(total_magnitude)
     measure_f0_variability8('--audio', audio, '--gcif', gcif, '--vari', tf0var)
     load(tf0var, 'magnitude')
     total_magnitude = magnitude;
  end
end
disp('Done.')


% Dump everything on disk
fid = fopen(out, 'at');
if dir(out).bytes == 0
   fprintf(fid, ['SpkID\tFileID\tMedianF1\tMedianF2\tMedianF3\tMedianF4\t' ...
              'MeanF1\tMeanF2\tMeanF3\tMeanF4\t' ...
              'StdF1\tStdF2\tStdF3\tStdF4\t' ...
              'DurVowel\tReadDur\tJitter\t' ...
              'TotalF0var\tMeanF0\tMedianF0\tStdF0\t' ...
              'SkewF0\tKurtF0\tMeanMFDR\tMedianMFDR\tStdMFDR\t' ...
              'SkewMFDR\tKurtMFDR\t' ...
              'MeanNAQ\tMedianNAQ\tStdNAQ\tSkewNAQ\tKurtNAQ\t' ...
              'MeanAmp\tMedianAmp\tStdAmp\tSkewAmp\tKurtAmp\t' ...
              'MeanH1H2\tMedianH1H2\tStdH1H2\tSkewH1H2\t' ...
              'KurtH1H2\t' ...
              'MeanHRF\tMedianHRF\tStdHRF\tSkewHRF\tKurtHRF\t' ... 
	      'MagnF0var\tCentF0Var\tSpreadF0var\tSkewF0var\tKurtF0var\n']);
end
fprintf(fid, ['%s\t%s\t%f\t%f\t%f\t%f\t%f\t%f\t' ...
        '%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t' ...
        '%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t' ...
        '%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t' ...
        '%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t' ...
	'%f\t%f\t%f\t%f\t%f\n'], ...
        base_name(1:5), base_name(7:end-13), ...
        formant_median(1), formant_median(2), formant_median(3), ...
        formant_median(4), formant_mean(1), formant_mean(2), ...
        formant_mean(3), formant_mean(4), formant_standard_deviation(1), ...
        formant_standard_deviation(2), formant_standard_deviation(3), ...
        formant_standard_deviation(4), duration_vowel, reading_duration, ...
        jitter_value, total_magnitude, source.f0(1), source.f0(2), ...
        source.f0(3)-source.f0(1), ...
        source.f0(5), source.f0(6), source.mfdr(1), ...
        source.mfdr(2), source.mfdr(3)-source.mfdr(1), source.mfdr(5), ...
        source.mfdr(6), source.naq(1), source.naq(2), ...
        source.naq(3)-source.naq(1), ...
        source.naq(5), source.naq(6), source.pa(1), ...
        source.pa(2), source.pa(3)-source.pa(1), source.pa(5), ...
        source.pa(6), source.h1h2(1), source.h1h2(2), ...
        source.h1h2(3)-source.h1h2(1), ...
        source.h1h2(5), source.h1h2(6), source.hrf(1), ...
        source.hrf(2), source.hrf(3)-source.hrf(1), source.hrf(5), ...
        source.hrf(6), spectral_magnitude, spectral_centroid, spectral_spread, ...
	spectral_skewness, spectral_kurtosis);
fclose(fid);


system([ 'rm -f ' audio ' ' formant ' ' formant_aggregated ' ' clip ' ' ...
         clip_gci ' ' phnm ' ' jitter ' ' duration_aggregated ' ' gcif ' ' ...
         sf0var ' ' sf0var_aggregated ' ' tf0var ]);
