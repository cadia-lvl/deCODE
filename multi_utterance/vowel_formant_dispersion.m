function dispersion = vowel_formant_dispersion(formant_frequencies_i, ...
                                               formant_frequencies_a, ...
                                               formant_frequencies_o, ...
                                               formant_frequencies_u)

formant_frequencies_i = formant_frequencies_i(:);
formant_frequencies_a = formant_frequencies_a(:);
formant_frequencies_o = formant_frequencies_o(:);
formant_frequencies_u = formant_frequencies_u(:);

first_midpoint = mean([formant_frequencies_i(1) formant_frequencies_a(1) ...
                    formant_frequencies_o(1) formant_frequencies_u(1)]);

second_weighted_sum = 0;
number_nonzeros = 0;
if formant_frequencies_i(1) < first_midpoint
  second_weighted_sum = second_weighted_sum + formant_frequencies_i(2);
  number_nonzeros = number_nonzeros + 1;
end
if formant_frequencies_a(1) < first_midpoint
  second_weighted_sum = second_weighted_sum + formant_frequencies_a(2);
  number_nonzeros = number_nonzeros + 1;
end
if formant_frequencies_o(1) < first_midpoint
  second_weighted_sum = second_weighted_sum + formant_frequencies_o(2);
  number_nonzeros = number_nonzeros + 1;
end
if formant_frequencies_u(1) < first_midpoint
  second_weighted_sum = second_weighted_sum + formant_frequencies_u(2);
  number_nonzeros = number_nonzeros + 1;
end
second_weighted_midpoint = second_weighted_sum / number_nonzeros;

center = [first_midpoint;second_weighted_midpoint];
dispersion = zeros(4, 1);
dispersion(1) = norm( formant_frequencies_i(1:2) - center );
dispersion(2) = norm( formant_frequencies_a(1:2) - center );
dispersion(3) = norm( formant_frequencies_o(1:2) - center );
dispersion(4) = norm( formant_frequencies_u(1:2) - center );
