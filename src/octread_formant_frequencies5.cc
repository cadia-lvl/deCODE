#include <octave/oct.h>

int count_frames(double *max_intensity, double *vowel_duration,
                 const char *file);

void read_formant_frequencies5(double *f1, double *f2, double *f3, double *f4,
			       const char *file, double max_intensity,
                               int number_frames);

DEFUN_DLD(octread_formant_frequencies5, args, nargout,
          "Interface to the formant frequency reader in C++.") {
  octave_value_list retval;
  const charMatrix file = args(0).char_matrix_value();
  dim_vector dv = file.dims();
  const char *pointer_string = file.fortran_vec();
  char *c_string = new char[dv(1)+1];
  int i1, number_frames;
  double max_intensity;

  for (i1 = 0; i1 < dv(1); i1++) {
    c_string[i1] = pointer_string[i1];
  }
  c_string[dv(1)] = '\0';
  RowVector vowel_duration(1);
  number_frames = count_frames(&max_intensity, vowel_duration.fortran_vec(),
                               c_string);
  ColumnVector f1(number_frames);
  ColumnVector f2(number_frames);
  ColumnVector f3(number_frames);
  ColumnVector f4(number_frames);
  read_formant_frequencies5(f1.fortran_vec(), f2.fortran_vec(),
                            f3.fortran_vec(), f4.fortran_vec(), c_string,
                            max_intensity, number_frames);
  delete [] c_string;

  retval(0) = octave_value(f1);
  retval(1) = octave_value(f2);
  retval(2) = octave_value(f3);
  retval(3) = octave_value(f4);
  retval(4) = octave_value(vowel_duration);

  return retval;
}
