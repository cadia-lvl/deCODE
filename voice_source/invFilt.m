function [flow, gci] = invFilt(wave,fs_orig)


fs = 20000;

% Load speech
sp = resample(wave,fs,fs_orig); 
sp = sp * 10^6; % converting to cubic cm per sec

% Obtain GCI and GOIs
voicebox('dy_cpfrac', 0.35);
[gci,~,gcic,goic,gdwav,udash,crnmp] = dypsagoi2(sp,fs);
goi = pickGOIs(gci, goic);

% glottal flow estimation
par = projParam('rgauss');
[flow, ar] = weightedlpc3(sp, gci, goi, fs, par);
