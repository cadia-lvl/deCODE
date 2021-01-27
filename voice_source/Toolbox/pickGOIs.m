function goi = pickGOIs(gci, goic)

% Copyright 2017 Yu-Ren Chien and Jon Gudnason
%
% This file is part of EGIFA.
%
% EGIFA is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% EGIFA is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with EGIFA.  If not, see <http://www.gnu.org/licenses/>.

% A priori optimal point in cycle
APOP = voicebox('dy_cpfrac');

% Determine larynx cycle durations
dgci = diff(gci);
dgci(end+1) = dgci(end);  %zero order approximation

goi=zeros(size(gci));
for ii=1:length(gci)
    % A priori optimal point
    coc = gci(ii)+ceil(APOP*dgci(ii));
        
    % Candidates inside cycle
    goics=goic(gci(ii)<goic&goic<gci(ii)+dgci(ii));
    
    if ~isempty(goics)  % We have candidates in the cycle. Let's pick one
        % Distances of cycles from "a priori optimal point"
        dcoc = (goics - coc(ones(size(goics)))).^2;
        
        % Pick the GOI
        [~,ix]=min(dcoc);
        goi(ii) = goics(ix);
    else  % We don't have a candidate in the cycle.  Need to guess, so using a priori choice
        goi(ii) = coc;
    end;
    
    
end;


%%
if nargout == 0 
figure(432); clf;
%plot(gdwav,'k'); hold on;
stem(gci,12*ones(size(gci)),'bx'); hold on;
stem(goic,10*ones(size(goic)),'co');
stem(goi,12*ones(size(goi)),'mx');
end