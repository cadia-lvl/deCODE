function magnitude_segments = analyze_segments_jitter(audio, phnm)

which_slash = find(audio == '/');
if isempty(which_slash)
  base_name = audio(1:end-4);
else
  base_name = audio(which_slash(end)+1:end-4);
end
clip = [base_name '_clip.wav'];
jitter = [base_name '_jitter.txt'];

[signal, rate] = wavread(audio);
load(phnm, 'start_vector', 'duration_vector', 'phoneme_vector')
number_segments = length(start_vector);
magnitude_segments = zeros(number_segments, 1);

number_vowel_segments = 0;
for i1 = 1:number_segments,
  if is_vowel(phoneme_vector(i1))
    number_vowel_segments = number_vowel_segments + 1;
    oa = start_vector(i1) + 0.5 * duration_vector(i1);
    center = round( rate * oa );
    oa = 0.5 * duration_vector(i1);
    half = round( rate * oa );
    magnitude = [];
    dilation = 1;
    full_duration = 0;
    while isempty(magnitude) && ... % segment not long enough for Praat
          ~full_duration,
      from = 1 + center - half * dilation;
      to = 1 + center + half * dilation;
      if from <= 1 && to >= length(signal)
        full_duration = 1;
      end
      oa = max(1,from) : min(length(signal),to);
      wavwrite(signal(oa), rate, clip)
      system(['./pitch/praat --run ' ...
              'measure_f0_variability7.praat ' clip ' > ' jitter]);
      fid = fopen(jitter, 'rt');
      magnitude = fscanf(fid, '%f', 'C');
      fclose(fid);
      dilation = dilation * 2;
    end
    if isempty(magnitude)
      magnitude = nan;
    end
    magnitude_segments(number_vowel_segments) = magnitude;
  end
end
magnitude_segments(number_vowel_segments+1:end) = [];

function y = is_vowel(phoneme)

y = 0;
if phoneme >= 11 && phoneme <= 34 | ...
      phoneme >= 43 && phoneme <= 50 | ...
      phoneme >= 59 && phoneme <= 66 | ...
      phoneme >= 103 && phoneme <= 110 | ...
      phoneme >= 139 && phoneme <= 146 | ...
      phoneme >= 171 && phoneme <= 206 | ...
      phoneme >= 211 && phoneme <= 218 | ...
      phoneme >= 227 && phoneme <= 238
  y = 1;
end
