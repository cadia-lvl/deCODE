function [magnitude_segments, length_segments] = ...
    analyze_segments_total(audio, gcif, phnm)

which_slash = find(audio == '/');
if isempty(which_slash)
  base_name = audio(1:end-4);
else
  base_name = audio(which_slash(end)+1:end-4);
end
clip = [base_name '_clip.wav'];
clip_gci = [base_name '_clip_gci.wav'];
tf0var = [base_name '_tf0var.mat'];

[signal, rate] = wavread(audio);
load(gcif, 'gci')
gci_all = gci;

load(phnm, 'start_vector', 'duration_vector', 'phoneme_vector')
number_segments = length(start_vector);
magnitude_segments = zeros(number_segments, 1);
length_segments    = zeros(number_segments, 1);
number_vowel_segments = 0;
for i1 = 1:number_segments,
  if is_vowel(phoneme_vector(i1))
    number_vowel_segments = number_vowel_segments + 1;
    start = round(rate*start_vector(i1)) + 1;
    ending = round(rate*start_vector(i1)) + round(rate*duration_vector(i1));
    oa = max(1,start):min(length(signal),ending);
    wavwrite(signal(oa), rate, clip)
    boundary = round(20e3*start_vector(i1)) + ...
        [1 round(20e3*duration_vector(i1))];
    gci = gci_all( gci_all>=boundary(1) & gci_all<=boundary(2) );
    if length(gci) < 3
      [oa1, oa2] = sort(abs( gci_all - mean(boundary) ));
      gci = gci_all(oa2(1:3));
      gci = sort(gci);
    end
    gci = gci - boundary(1) + 1;
    save(clip_gci, 'gci')
    measure_f0_variability6('--audio', clip, '--gcif', ...
                            clip_gci, '--vari', tf0var)
    load(tf0var, 'magnitude')
    magnitude_segments(number_vowel_segments) = magnitude;
    length_segments   (number_vowel_segments) = length(gci);
  end
end
magnitude_segments(number_vowel_segments+1:end) = [];
length_segments   (number_vowel_segments+1:end) = [];

function y = is_vowel(phoneme)

y = 0;
if phoneme >= 11 & phoneme <= 34 || ...
      phoneme >= 43 & phoneme <= 50 || ...
      phoneme >= 59 & phoneme <= 66 || ...
      phoneme >= 103 & phoneme <= 110 || ...
      phoneme >= 139 & phoneme <= 146 || ...
      phoneme >= 171 & phoneme <= 206 || ...
      phoneme >= 211 & phoneme <= 218 || ...
      phoneme >= 227 & phoneme <= 238
  y = 1;
end

%system([ 'rm -f ' tf0var]);
