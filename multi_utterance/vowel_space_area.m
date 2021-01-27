function area = vowel_space_area(formant_frequencies_i, ...
                                 formant_frequencies_a, ...
                                 formant_frequencies_o, ...
                                 formant_frequencies_u)

formant_frequencies_i = formant_frequencies_i(:);
formant_frequencies_a = formant_frequencies_a(:);
formant_frequencies_o = formant_frequencies_o(:);
formant_frequencies_u = formant_frequencies_u(:);

area = polyarea([formant_frequencies_i(1);formant_frequencies_a(1);...
                 formant_frequencies_o(1);formant_frequencies_u(1)], ...
                [formant_frequencies_i(2);formant_frequencies_a(2);...
                 formant_frequencies_o(2);formant_frequencies_u(2)]);
