function par = projParam(wparmethod)

if nargin == 0
    wparmethod = 'ame';
end;

% Parameters for weights
par.wpar.method = wparmethod;
par.wpar.fs = 20000;

switch par.wpar.method
    case 'cp'
        par.wpar.minF0 = 50;  % Hz (assume that no voice has lower f0)
        par.wpar.cpFrac = 0.8;  % Assumed proportion of closed phase in a cycle
        par.wpar.cpDelay = 0.9e-3; % in s. Closed analysis begins after GCI
    case 'ame'
        par.wpar.minF0 = 50;  % Hz (assume that no voice has lower f0)
        par.wpar.d = 0.05;  % Amplitude parameter 0.01  (SEE: Fig 1 in Alku et.al "Improved formant frequency ...")
        par.wpar.DQ = 0.4;  % Duration quotient  0.4
        par.wpar.PQ = 0.8;  % Position quotient 0.8
        par.wpar.rlen =  9;   % Ramp length   3
    case 'rgauss'
        par.wpar.kappa = 0.9;
        par.wpar.sig=sqrt(50);
    otherwise 
        error('Unknown weighted LP method');
end


%par.wpar.minF0 = 50;  % Hz (assume that no voice has lower f0)
%par.wpar.cpFrac = 0.2;  % Assumed proportion of closed phase in a cycle
%par.wpar.cpDelay = 0.5e-3; % in s. Closed analysis begins after GCI


% Parameters for determining frame boundaries  VALUES FROM IAIF :
par.fpar.wl = 32e-3;  % window size in samples (25 ms)
par.fpar.inc = 16e-3; % frame increment in samples (10 ms)

% LPC modeling parameters
par.mpar.f_preemph = 10; % Hz  (Preemphasis cutoff)
% par.mpar.windowFunction = @hamming;
par.mpar.fade = 0;
