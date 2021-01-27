function parse_one_ctm(ctm, phnm, start_ms)

the_subject = '';
start_vector = [];
duration_vector = [];
phoneme_vector = [];
fid = fopen(ctm, 'rt');
line_text = fgetl(fid);

while ischar(line_text),
  [subject, type, start, duration, phoneme] = ...
      sscanf(line_text, '%5s_Measure%s 1 %f %f %f', 'C');
  if strcmp(type, 'Reading')
    if ~strcmp(the_subject, subject)
      the_subject = subject;
      start_vector = [];
      duration_vector = [];
      phoneme_vector = [];
    end
    start_vector = [start_vector start-start_ms/1000];
    duration_vector = [duration_vector duration];
    phoneme_vector = [phoneme_vector phoneme];
  end
  
  line_text = fgetl(fid);
end
fclose(fid);
if ~isempty(the_subject)
  save(phnm, 'start_vector', 'duration_vector', ...
       'phoneme_vector')
end
