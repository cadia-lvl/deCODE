function out = f0var(gci)

% F0 variability computation
% GCIs a in seconds not samples - it fails otherwise!!!
% 1st - Interpolates diff. GCI with a spline and then decomposes
% 2nd - Assumes that the singal is composed of "true" f0 countours (LowFreq)
%       and some variation (HighFreq) - Ws set to 6Hz = 150ms a standard length of vowel a
% The output is a relative number in percent


spline_fs= 2e3;
%% interpolate with fs=2e3, need to remove outliers 1st
t = gci;
if length(t) > 10
    dt = MAD_outliers(diff(t));
    t = t(2:end);
    xi = t(1):1/spline_fs:t(end);
    spline = interp1(t,dt,xi,'spline');
else
    disp('Not enough GCI samples, need more than 10.');
    out = NaN;
    return;
end  

%% Variability computation

Ws = 6/(spline_fs/2);
[bh,ah] = cheby2(4,40,Ws,'high');
[bl,al] = cheby2(4,40,Ws,'low');
sigl = filtfilt(bl,al,spline);
sigh = filtfilt(bh,ah,spline);
out = sum(sigh.*sigh)/sum(sigl.*sigl)*100;
out = out(:);
