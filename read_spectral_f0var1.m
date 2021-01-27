function [magnitude_selected, centroid_selected, spread_selected, ...
          skewness_selected, kurtosis_selected] = ...
    read_spectral_f0var1(file, alignment)

if isempty(alignment) % not reading
  load(file, 'magnitude', 'centroid', 'spread', 'skewness', 'kurtosis', ...
       'time_position', 'intensity')
else % reading
  load(file, 'magnitude', 'centroid', 'spread', 'skewness', 'kurtosis', ...
       'time_position')
end
which_nonzero = magnitude ~= 0;
magnitude = magnitude(which_nonzero);
centroid = centroid(which_nonzero);
spread = spread(which_nonzero);
skewness = skewness(which_nonzero);
kurtosis = kurtosis(which_nonzero);
time_position = time_position(which_nonzero);
if isempty(alignment)
  intensity = intensity(which_nonzero);
end

if ~isempty(alignment)
  oa = find(file == '/');
  selected = logical(zeros(size(time_position)));
  load(alignment, 'start_vector', 'duration_vector', 'phoneme_vector')
  number_segments = length(start_vector);
  for i1 = 1:number_segments,
    if is_vowel(phoneme_vector(i1))
      segment = time_position>=start_vector(i1) & ...
                time_position<=start_vector(i1)+duration_vector(i1);
      selected = selected | segment;
    end
  end
else
  selected = intensity > max(intensity)/3;
end
magnitude_selected = magnitude(selected);
centroid_selected  = centroid (selected);
spread_selected    = spread   (selected);
skewness_selected  = skewness (selected);
kurtosis_selected  = kurtosis (selected);

function y = is_vowel(phoneme)

y = 0;
if phoneme >= 11 & phoneme <= 34 | ...
      phoneme >= 43 && phoneme <= 50 | ...
      phoneme >= 59 && phoneme <= 66 | ...
      phoneme >= 103 && phoneme <= 110 | ...
      phoneme >= 139 && phoneme <= 146 | ...
      phoneme >= 171 && phoneme <= 206 | ...
      phoneme >= 211 && phoneme <= 218 | ...
      phoneme >= 227 && phoneme <= 238
  y = 1;
end
