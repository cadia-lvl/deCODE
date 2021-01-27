% Length of ww fixed. A non-voiced period can occur at the start of signal.

function w = weightsForLP3(gci, goi, nsp, par)

%weightsForLP compute weight vector for weighted linear prediction w = (gci, goi, nsp, par)
%
%  Inputs:  gci     glottal closure instants (in samples)
%           goi     glottal opening instants (in samples)
%           nsp     length of speech signal (in samples)
%           par     Includes parameters that are needed for each method
%           par.method indicates which method to use
%                   
% Outputs:  w       Weight vector of size nsp x 1


switch lower(par.method)
    case 'cp'
        %Get parameters from par
        minF0 = par.minF0;
        cpDelay = par.cpDelay;
        cpFrac = par.cpFrac;
        
        fs = par.fs;
        
        maxSamplesPerCycle = ceil(fs/minF0);
        cpDelay=round(cpDelay*fs);

        
        % Cycle stat
        dgci = [diff(gci) gci(end)-gci(end-1)];
        dgoi = [diff(goi) goi(end)-goi(end-1)];
        CQ = goi-gci;
        
        %Add cpDelay to GCI (carefully)
        adgci = gci+min(cpDelay,round(0.2*CQ));  % Don't advance the GCI further than 20% of the CP
        %ddgoi = goi+min(cpDelay,round(0.2*CQ));
        
        w = zeros(nsp,1);
        w(adgci) = 1;
        w(goi) = -1;
        w = cumsum(w);
        
        %Finding non-voiced periods in the speech segmant
        ww = zeros(nsp,1);
        igoi = dgoi>maxSamplesPerCycle;  %Indices of goi's where non-voiced period begins
        igoi(1) = 0;
        
        % Start non-voiced segment where the next GCI would be (based on previous
        % cycle and cpfrac
        ww(goi(igoi)+round((1-cpFrac)*dgci(find(igoi)-1))) = 1;
        ww(gci(igoi)+dgci(igoi)) = -1;
        ww = cumsum(ww);
        
        % Add a one period to the start and end of the signal
        ww(1:gci(1)-1) = 1;
        ww(goi(end)+round((1-cpFrac)*dgci(end)):end)=1;
        
        ww(nsp+1:end) = [];
        w = w + ww;
        
        %Just in case
        w = min(w,ones(size(w)));
        w = max(w,zeros(size(w)));
        
        w(w==0) = 0.0;
        
    case 'rgauss'
        %Get parameters from par
        kappa = par.kappa;
        sig = par.sig;
 
        sig2=sig^2;
        nn=(1:nsp)';
        gg = zeros(nsp,1);
        for ii =1:length(gci)
            %gg = gg +  kappa*normpdf(nn,gci(ii), sig);
            gg = gg +  kappa*exp(-(nn-gci(ii)).^2/sig2);
        end;
        
        w = 1 - gg;
        
    case 'ame'  %AME : Attenuated Main Excitation
        %Get parameters from par
        minF0 = par.minF0;
        d = par.d;
        DQ = par.DQ;
        PQ = par.PQ;
        rlen = par.rlen;
        
        fs = par.fs;
        maxSamplesPerCycle = ceil(fs/minF0);
        
        T = [diff(gci) gci(end)-gci(end-1)];
        igci = T > maxSamplesPerCycle;
        igci(1) = 0;
        T(igci) = T(find(igci)-1);  % Dealing with unvoiced periods (set pitch period of last pitch in a voiced spurt equal to one before)
        dramp = linspace(1,d,rlen+1);% dramp = dramp(2:end);
        uramp = linspace(d,1,rlen+1);% uramp = uramp(1:end-1);
        
        w = zeros(nsp,1); tep=1;
        for ii = 1:length(gci)
            ts = gci(ii)-round(PQ*DQ*T(ii));
            tsm = ts-rlen;
            
            w(tep:tsm) = 1;
            w(tsm:ts) = dramp;
            
            te = ts + round(DQ*T(ii));
            tep = te + rlen;
            
            w(ts:te) = d;
            w(te:tep) = uramp;
            
        end;
        
    otherwise
        error(['Unknown method ' par.method]);
        
end;

