function  out = parse_vowel_ctm(ctm)

fid = fopen(ctm, 'r');
line_text = fgetl(fid);
tmp = [];

while ischar(line_text),
  [~,~,start, duration, phoneme] = sscanf(line_text, '%5s_Measure%s 1 %f %f %f', 'C');
  if phoneme > 10
    vect = zeros(1,2);
    vect(1) = start;
    vect(2) = start+duration;
    tmp =  [tmp;vect];
  end
  line_text = fgetl(fid);
end

out(1) = tmp(1,1);
out(2) = tmp(end,2);

fclose(fid);
