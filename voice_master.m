function res = voice_master(audio,gender,mark_b,mark_e,ctm)
% Master file to compute voice source characteristics
% Inputs- audio   = audio file, not a wave
%	- gender  = gender of the participant
%	- mark_b  = starting mark of speech
%	- mark_e  = ending mark of the speech
%	- ctm = ctm file with phoneme timestams, outfrom from PhnAli
%
% Output - res = a structure that contains 
%		- jitter = a scalar total f0 variability measure
%		- f0 = a vector of mean,median,mean+std,mean-std,skewness, kurtosis of F0 
%		- mfdr = a vector of mean,median,mean+std,mean-std,skewness, kurtosis of maximum flow declination rate 
%		- naq = a vector of mean,median,mean+std,mean-std,skewness, kurtosis of normalizes amplitude quotient 
%		- pa = a vector of mean,median,mean+std,mean-std,skewness, kurtosis of  pulse amplitude
%		- h1h2 = a vector of mean,median,mean+std,mean-std,skewness, kurtosis of H1-H2 difference
%		- hrf = a vector of mean,median,mean+std,mean-std,skewness, kurtosis of harmonic richness factor
%
% mfiles used to extract each parameter is in separate folder, see there for more info


pkg load signal
pkg load statistics
addpath preprocess
addpath pitch
addpath voice_source
addpath voice_source/voicebox
addpath voice_source/DYPSAGOI
addpath voice_source/Toolbox
addpath f0var
addpath common

## Variables
tmpdir = strcat(pwd,'/tmp');
mkdir(tmpdir);
[~,name,~] = fileparts(audio);
[wave,fs] = wavread(audio);

# Split Reading based on ctm
if regexpi(audio,'Reading')
   list_b = [];
   list_e = [];
   [~,ali] = import_ctm(ctm);
   ali = cell2mat(ali);
   tmp = [];

   for i = 1:size(ali,1)
      if ali(i,3) > 10
         tmp = [tmp; ali(i,:)];
      else
         if ~isempty(tmp)
	       if (tmp(end,2) - tmp(1,1) > 0.5)
                  list_b = [list_b; tmp(1,1)*1000];
                  list_e = [list_e; tmp(end,2)*1000];
               endif
               tmp = [];
         endif
      endif
   endfor
   if ~isempty(tmp)
      if (tmp(end,2) - tmp(1,1) > 0.5)    
          list_b = [list_b; tmp(1,1)*1000];
          list_e = [list_e; ali(i,2)*1000];
      endif
   endif
else
   list_b = [mark_b];
   list_e = [mark_e];
endif

[f0,mfdr,pa,naq,h1h2,hrf,jitter] = deal([]);
for i = 1:length(list_b)
   mark_b = list_b(i);
   mark_e = list_e(i);

   ## Speech wave preprocessing
   wave_seg = preprocess(wave,fs,mark_b,mark_e);

   ## Extract pitch
   wfile = strcat(tmpdir,'/',name,'.wav');
   pfile  = strcat(tmpdir,'/',name,'.f0');
   script = 'pitch/scriptF0.praat';
   cmd = 'pitch/praat';

   wavwrite(wave_seg, fs, wfile);
   f0_tmp = PraatPitch(wfile,pfile,cmd,script,gender,ctm);
   f0_tmp = f0_tmp(~isnan(f0_tmp(:)));
   f0 = [f0;f0_tmp];
   delete(wfile);

   ## Other voice source features
   wave_seg = resample(wave_seg, 20e3, fs);
   [flow, gci]= invFilt(wave_seg,fs);
   [mfdr_tmp, pa_tmp, naq_tmp, h1h2_tmp, hrf_tmp] = extractVoiceFeatures(flow, fs, gci);
   mfdr = [mfdr;mfdr_tmp];
   pa = [pa;pa_tmp];
   naq = [naq;naq_tmp];
   h1h2 = [h1h2;h1h2_tmp];
   hrf = [hrf;hrf_tmp];
   jitter = [jitter; f0var(gci/20e3)];

   ## F0 variability from GCIs (that are sampled with fs=20e3)
endfor

## Compute stats

res.jitter = nanmean(jitter);
res.f0=get_stats(MAD_outliers(f0));
res.mfdr=get_stats(MAD_outliers(mfdr));
res.pa=get_stats(MAD_outliers(pa));
res.naq=get_stats(MAD_outliers(naq));
res.h1h2=get_stats(MAD_outliers(h1h2));
res.hrf=get_stats(MAD_outliers(hrf));
res.gci = gci;
