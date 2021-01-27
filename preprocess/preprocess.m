function [wave,start_ms] = preprocess(wave,fs,varargin)

# Preprocessing tool to truncate signal using manual segmentation marks(optional) and LP-filer to remove LF noise.'
# Does not cut out speech segments, rather the beginning and end of speech as a whole
# The marks should be in [ms] not samples
# A function version of tool preprocess.m which is a script made to run from cmd line.'
# USAGE : preprocess(wave,fs[,begin_mark,end_mark])


## Check audio
wave = wave-mean(wave);
t_s = 0;
t_e = length(wave)/fs*1000;

## Segmentation marks
if length(varargin)
   t_s = varargin{1};
   t_e = varargin{end};
endif


# some checks
if t_e == 0 || t_e <= t_s
   t_e = length(wave)/fs*1000;
end

t_s = min(t_s, length(wave)/fs*1000-1);
t_e = min(t_e, length(wave)/fs*1000);

## HP filter with Butterworth
n=5;
Wn=60/(fs/2);
[b,a] = butter(n,Wn,'high');
wave=filtfilt(b,a,wave);


## VAD - not applied as results are not good
% vadout=apply_vad(wave,fs)

## Truncate
s_s = ceil(t_s/1000*fs)+1;
s_e = floor(t_e/1000*fs);

if s_s > 1
   wave = wave(s_s:s_e);
   start_ms = t_s;   
else
   p1=dot(wave(1:s_e),wave(1:s_e))/s_e;
   p2=dot(wave(s_e:end),wave(s_e:end))/(length(wave)-s_e);
   if p1 > p2
      wave = wave(1:s_e);
      start_ms = 0;
   else
      wave = wave(s_e:end);
      start_ms = t_e;
   endif
endif
##


