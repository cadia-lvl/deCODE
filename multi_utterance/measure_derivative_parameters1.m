function measure_derivative_parameters1(varargin)
% Usage: measure_derivative_parameters(..., 'options', ...)
%
% Options:
%
%   '--in', 'FILE'         File name for all the single-utterance results.
%
%   '--out', 'FILE'        Name of the output text file.
%
pkg load statistics

in = '';
out = '';
ind_arg = 1;
while ind_arg <= nargin,
  switch varargin{ind_arg}
    case '--in'
      ind_arg = ind_arg + 1;
      if ind_arg <= nargin
        in = varargin{ind_arg};
      else
        disp('measure_derivative_parameters.m: input file name missing')
      end
    case '--out'
      ind_arg = ind_arg + 1;
      if ind_arg <= nargin
        out = varargin{ind_arg};
      else
        disp('measure_derivative_parameters.m: output file name missing')
      end
    otherwise
      error(['measure_derivative_parameters.m: unrecognized argument ' ...
             varargin{ind_arg}])
  end
  ind_arg = ind_arg + 1;
end
if isempty(in)
  error('Input file name must be specified!')
end
if isempty(out)
  error('Output file name must be specified!')
end

empty_rows = repmat(nan, [5 1 4]);

subject = [];
formant_frequencies = zeros(5, 0, 4); % 5 vowel types, 4 formants
fid = fopen(in, 'rt');
line_text = fgetl(fid);
while ischar(line_text),
  if ~strcmp(line_text(1:5), 'SpkID')
    median_formant = zeros(4, 1);
    [speaker_id, file_id, median_formant(1), median_formant(2), ...
	       median_formant(3), median_formant(4)] = ...
      sscanf(line_text, '%f%s%f%f%f%f', 'C');
    index = find(subject==speaker_id);
    if isempty(index)
      index = length(subject) + 1;
      subject = [subject;speaker_id];
      formant_frequencies(:,index,:) = empty_rows;
    end
    switch file_id(8),
      case 'I'
        vowel = 1;
      case 'E'
        vowel = 2;
      case 'A'
        vowel = 3;
      case 'O'
        vowel = 4;
      case 'U'
        vowel = 5;
      otherwise
        vowel = 0;
    end
    if vowel
      for i1 = 1:4, % each formant
        if isnan(formant_frequencies(vowel,index,i1))
          formant_frequencies(vowel,index,i1) = median_formant(i1);
        else
          oa = formant_frequencies(vowel,index,i1) + median_formant(i1);
          formant_frequencies(vowel,index,i1) = oa / 2;
        end
      end
    end
  end

  line_text = fgetl(fid);
end
fclose(fid);

[oa1, oa2] = sort(subject);
subject = subject(oa2);
formant_frequencies = formant_frequencies(:,oa2,:);
number_subjects = length(subject);
dispersion = zeros(4, number_subjects);
area = zeros(number_subjects, 1);
area_e = zeros(number_subjects, 1);
centralization = zeros(number_subjects, 1);
for i1 = 1:number_subjects,
  i_median = formant_frequencies(1,i1,:);
  e_median = formant_frequencies(2,i1,:);
  a_median = formant_frequencies(3,i1,:);
  o_median = formant_frequencies(4,i1,:);
  u_median = formant_frequencies(5,i1,:);
  dispersion(:,i1) = vowel_formant_dispersion(i_median, a_median, ...
                                              o_median, u_median);
  area(i1) = vowel_space_area(i_median, a_median, o_median, ...
                              u_median);
  area_e(i1) = vowel_space_area(i_median, a_median, e_median, ...
                                u_median);
  centralization(i1) = formant_centralization_ratio(i_median, ...
                                                    a_median, ...
                                                    u_median);
  vtl_f1(i1) = 353/(4*mean(mean(formant_frequencies(:,i1,1))));
  vtl_f2(i1) = 3*353/(4*mean(mean(formant_frequencies(:,i1,2))));
  vtl_f3(i1) = 5*353/(4*mean(formant_frequencies(:,i1,3)));
  vtl_all(i1) = nanmean([vtl_f1,vtl_f2,vtl_f3]);
end

fid = fopen(out, 'wt');
fprintf(fid, 'SpkID\tVFD_I\tVFD_A\tVFD_O\tVFD_U\tVSA4o\tVSA4e\tFCR\tVTL_F3\n');
for i1 = 1:number_subjects,
  fprintf(fid, '%05d\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\n', ...
	  subject(i1), dispersion(1,i1), dispersion(2,i1), dispersion(3,i1), ...
	  dispersion(4,i1), area(i1), area_e(i1), centralization(i1), vtl_f3(i1)*100);
end
fclose(fid);
