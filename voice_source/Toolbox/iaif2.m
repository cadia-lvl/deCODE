% Using lpcifilt2.m.

function [udash ar Ts u] = iaif2(sp,fs,p,g,r,h)

%   Implementation of the Iterative Adaptive Inverse Filtering (IAIF)
%   Algorithm for Glottal Wave Analysis
%
%   [udash ar Ts u] = iaif(sp,fs,p,g,r,h)
%
%   Inputs:
%       sp      Nx1 vector speech signal
%       fs      Sampling freq (Hz)
%       p       (Optional) First vocal tract LPC order (8-12, default=10)
%       g       (Optional) Glottal source LPC order (2-4, default=4)
%       r       (Optional) Second vocal tract LPC order (8-12, default=10)
%       h       (Optional) 0-don't HPF at 60 kHz (default=1)
%
%   Outputs:
%       udash   Nx1 vector of glottal flow derivative
%       ar      
%       Ts
%       u       Nx1 vector of glottal flow
%
%   Notes:
%       1. Based upon algorithm definition in Alku1999.
%       2. LPC orders specified for 8k sampling only; inputs resampled if
%          necessary.
%       3. 'Integrator' assumed to mean 'slightly leaky integrator'.
%       4. LPC overlap of 50% assumed.
%       5. Highpass order assumed to be 1024.
%       6. Mark's preferred parameter sets: 8k:   p=8;g=2;r=8;
%                                           20k:  p=20;g=4;r=20;
%
%   External Functions:
%       Functions lpcauto and lpcifilt in Voicebox required.
%
%   References:
%       P. Alku, "Glottal Wave Analysis with Pitch Synchronous Iterative
%       Adaptive Filtering," Speech Communication, 1992, 11(2-3), 109-118.
%       
%       P. Alku, H. Tiitinen and R. Naatanen, "A Method for Generating
%       Natural-Sounding Speech Stimuli for Cognitive Brain Research,"
%       Clinical Neurophysiology, May 1999, 110(8), 1329-1333.
%
%**************************************************************************
% Author:           M. R. P. Thomas 
% Date:             28 April 2009
% Last Modified:    29 April 2009
%**************************************************************************

lpcdur=0.032;       % As in Alku1992a. Not stated in Alku1999.
lpcstep=lpcdur/2;   % 50% overlap assumed.

%if~(fs==8000)
%    warning('fs!=8000. Consider resampling');
%end

% LPC Orders. 8k recommendation: 8<=p<=12, 2<=g<=4, 8<=r<=12.
% Alku1992a set
if(nargin<6)
    h = 1;
end
if(nargin<5)
    r=10;
end
if(nargin<4)
    g=4;
end
if(nargin<3)
    p=10;
end

% MRPT's Alternative LPC parameter sets. Can it be made fs-dependent?
% 8k:   p=8;g=2;r=8;
% 20k:  p=25;g=4;r=25;

% 'Integrator' undefined - assume slightly leaky.
intb=1;
inta=[1 -0.95];

% 1. Highpass - 60k in Alku1999 and 30k in PSIAIF. May even make external.
if(h==1)
    b = fir1(1024,60/(fs/2),'high');
    spf=fftfilt(b,sp);
    delay=round(mean(grpdelay(b)));
    spf = [spf(delay+1:end); zeros(delay, 1)];
else
    spf=sp;
end

% 2. Order-1 LPC
[Hg1, eHg1, TsHg1] = lpcauto(spf,1,floor([lpcstep lpcdur]*fs));

% 3. Inverse-filtering
spHg1 = lpcifilt2(spf,Hg1,TsHg1);

% 4. p-th-order LPC
[Hvt1, eHvt1, TsHvt1] = lpcauto(spHg1,p,floor([lpcstep lpcdur]*fs));

% 5. Inverse-filtering
spHvt1 = lpcifilt2(spf,Hvt1,TsHvt1);

% 6. Integrate
spHvt1_I = filter(intb,inta,spHvt1);

% 7. g-th order LPC
[Hg2, eHg2, TsHg2] = lpcauto(spHvt1_I,g,floor([lpcstep lpcdur]*fs));

% 8. Inverse-filtering
spHg2 = lpcifilt2(spf,Hg2,TsHg2);

% 9. Integrate - not done in Alku1992 but is in Alku1999
spHg2_I = filter(intb,inta,spHg2);

% 10. r-th order LPC
[Hvt2, eHvt2, TsHvt2] = lpcauto(spHg2_I,r,floor([lpcstep lpcdur]*fs));

% 11. Inverse-filtering
spHvt2 = lpcifilt2(spf,Hvt2,TsHvt2);
udash = spHvt2;

ar=Hvt2;
Ts = TsHvt2;

% 12. Integration
g = filter(intb,inta,spHvt2);
u = g;
