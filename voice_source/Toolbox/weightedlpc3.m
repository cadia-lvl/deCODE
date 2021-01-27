% Using weightsForLP3.m. Using weightsForLP2.m.

function [uu,ar,ee,dc,w]=weightedlpc3(sp, gci, goi, fs, par)

nsp = length(sp);
nar = ceil(fs/1000);  % number of LPC poles: 1 pole per 1000 Hz.  Note: don't add the two poles that are normally thought of as representing lip and source


% Determine weight vector
wpar = par.wpar;
wpar.fs =fs;
w = weightsForLP3(gci, goi, nsp, wpar);

% Determine frame boundaries
fpar = par.fpar;
wl = round(fs*fpar.wl);
inc = round(fs*fpar.inc);


tstart = (nar+1):inc:(nsp-wl-1);
tend = tstart+wl;
T=[tstart(:) tend(:)];
T(:,tstart>nsp) = [];
T(:,tend>nsp) = [];

%%% Closed phase covariance analysis %%%
f_preemph = par.mpar.f_preemph; % Hz  (Preemphasis cutoff)
fade= par.mpar.fade;

b=[1 -exp(-2*pi*f_preemph/fs)];
sp_preemph = filter(b,1,sp);      %Estimate the AR on pre-emphasised signal

[ar,ee,dc]=lpccovar(sp_preemph, nar, T, w);
%ar2=ar.*repmat(sqrt(ee(:,1)),1,size(ar,2));
%dc=dc.*sqrt(ee(:,2));
uu=lpcifilt(sp, ar, T, dc,fade);

%u = filter(1,b,uu);
%u = adjustU(u,gci,goi);
