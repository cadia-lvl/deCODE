function C = PraatPitch(wavfile, praatfile, cmdPraat, script, sex, ctm)

# Setup
iwantfilecleanup = 1;
frameshift = 0;
minF0 = 75;
maxF0 = 400;
silthres = 0.1;
voicethres = 0.5;
octavecost = 0.1;
octavejumpcost = 0.5;
voiunvoicost = 0.25;
killoctavejumps = 1;
smooth = 1;
smoothbw = 5;
interpolate = 1;
method = 'ac';


%% Main function
if exist(wavfile, 'file') == 2
   cmd = sprintf('%s --run %s %s %s %s', cmdPraat, script, wavfile, praatfile, sex);
else
   disp('File does not exists.')
   return;
end

% call praat for Unix
err = unix(cmd);
if (err ~= 0)  %error
   disp('Error while calling Praat. Check the command :')
   disp (cmd)
   return;
end

% Read resulting file
fid = fopen(praatfile, 'rt');

try
   C = textscan(fid, '%f %f', 'delimiter', '\n', 'TreatAsEmpty', '--undefined--');
   C = cell2mat(C);
   C = C(:,2);
catch
   C=NaN;
end_try_catch

fclose(fid);


% Delete f.praat
if iwantfilecleanup
    if exist(praatfile,'file') == 2
        delete(praatfile);
    end
end
