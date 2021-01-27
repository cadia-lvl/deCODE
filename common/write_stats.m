#! /bin/octave -qf
pkg load signal

%%
usage_msg = 'Extracts f0 statistics using spk2utt file. Type -h for help.';
if ~nargin
 disp(usage_msg)
 return
end
std_out=1;
spk2utt='';

arg_list = argv();
ind_arg = 1;
while ind_arg <= nargin,
  switch arg_list{ind_arg}
    case {'-h', '--help', '-?'}
     disp(usage_msg)
     disp('Usage: get_stats -s <spk2utt> [-o <output_file>]')
    return
    case {'--spk2utt' '-s'}
      ind_arg = ind_arg + 1;
      if ind_arg <= nargin
        spk2utt = arg_list{ind_arg};
      else
	fprintf('Utt2spk file missing using, terminate\n')
        return;
      end
    case {'--out' '-o'}
      ind_arg = ind_arg + 1;
      if ind_arg <= nargin
        list = arg_list{ind_arg};
        std_out=0;
      end
    otherwise
      disp(['Unrecognized argument' arg_list{ind_arg}])
      return
  end
  ind_arg = ind_arg + 1;
end


fprintf('%s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s\n','ID','LongA_mean','LongA_med','LongA_low','LongA_high','LongA_skew','LongA_kurt','Read_mean','Read_med','Read_low','Read_high','Read_skew','Read_kurt','Global_mean','Global_med','Global_low','Global_high','Global_skew','Global_kurt');
fid = fopen(spk2utt, 'r');
tline = fgets(fid);
while ischar(tline)   
   [lA,rr,g] = deal([]);
   str = strsplit(tline,' ');
   id = str{1,1};
   for i = 2:length(str)
     [~,f0] = PraatF0_read(strtrim(str{i}));
     if regexp(str{i},'LongA')
	lA = f0;
     elseif regexp(str{i},'Reading')
        rr = f0;
     end
     g = [g;f0];
   end

   if isempty(lA) || isempty(rr)
      tline = fgets(fid);
      continue
   end

      med = median(lA);
      lA= lA(lA > med/2 & lA < med*2 );   
      rr= rr(rr > med/2 & rr < med*2 );
      g = g(g > med/2 & g < med*2 );
      fprintf('%s %4.2f %4.2f %4.2f %4.2f %4.2f %4.2f %4.2f %4.2f %4.2f %4.2f %4.2f %4.2f %4.2f %4.2f %4.2f %4.2f %4.2f %4.2f\n',id,mean(lA),median(lA),mean(lA)-std(lA),mean(lA)+std(lA),skewness(lA),kurtosis(lA),mean(rr),median(rr),mean(rr)-std(rr),mean(rr)+std(rr),skewness(rr),kurtosis(rr),mean(g),median(g),mean(g)-std(g),mean(g)+mean(g),skewness(g),kurtosis(g));
   tline = fgets(fid);
end
fclose(fid);	
