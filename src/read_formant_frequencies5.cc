// Absolute lower limit for voiced intensity. Estimating vowel duration.
// Using octstring_to_number.oct. Using default values for missing formants.

#include <iostream>
#include <fstream>

double string_to_number(const char *string);

int count_frames(double *max_intensity, double *vowel_duration,
                 const char *file) {
  double intensity, number_formants, hop_size;
  std::ifstream fid;
  int i1, number_frames;
  std::string line_text;

  *max_intensity = 0.0;
  fid.open(file);
  for (i1 = 1; i1 <= 6; i1++) {
    std::getline(fid, line_text);
  }
  std::getline(fid, line_text);
  hop_size = string_to_number(line_text.data());
  for (i1 = 8; i1 <= 9; i1++) {
    std::getline(fid, line_text);
  }
  while (std::getline(fid, line_text)) {
    intensity = string_to_number(line_text.data());
    if (intensity > *max_intensity) {
      *max_intensity = intensity;
    }
    std::getline(fid, line_text);
    number_formants = string_to_number(line_text.data());
    for (i1 = 0; i1 < int(number_formants)*2; i1++) {
      std::getline(fid, line_text);
    }
  }
  fid.close();

  number_frames = 0;
  *vowel_duration = 0.0;
  fid.open(file);
  for (i1 = 1; i1 <= 9; i1++) {
    std::getline(fid, line_text);
  }
  while (std::getline(fid, line_text)) {
    intensity = string_to_number(line_text.data());
    std::getline(fid, line_text);
    number_formants = string_to_number(line_text.data());
    for (i1 = 0; i1 < int(number_formants)*2; i1++) {
      std::getline(fid, line_text);
    }
    if (intensity > *max_intensity/2.0) {
      number_frames = number_frames + 1;
    }
    if (intensity > *max_intensity/10.0 && intensity > 1.0e-6) {
      *vowel_duration += hop_size;
    }
  }
  fid.close();

  return number_frames;
}

void read_formant_frequencies5(double *f1, double *f2, double *f3, double *f4,
			       const char *file, double max_intensity,
                               int number_frames) {
  double intensity, number_formants;
  std::ifstream fid;
  int i1, oai, ind;
  std::string line_text;
  
  fid.open(file);
  for (i1 = 1; i1 <= 9; i1++) {
    std::getline(fid, line_text);
  }
  ind = 0;
  while (std::getline(fid, line_text)) {
    intensity = string_to_number(line_text.data());
    std::getline(fid, line_text);
    number_formants = string_to_number(line_text.data());
    if (int(number_formants) > 4) {
      oai = int(number_formants);
    } else {
      oai = 4;
    }
    double *formant_frequencies = new double[oai];
    formant_frequencies[0] = 500.0;
    formant_frequencies[1] = 1500.0;
    formant_frequencies[2] = 2500.0;
    formant_frequencies[3] = 3500.0;
    for (i1 = 0; i1 < int(number_formants); i1++) {
      std::getline(fid, line_text);
      formant_frequencies[i1] = string_to_number(line_text.data());
      std::getline(fid, line_text); // formant bandwidth
    }
    if (intensity > max_intensity/2.0) {
      f1[ind] = formant_frequencies[0];
      f2[ind] = formant_frequencies[1];
      f3[ind] = formant_frequencies[2];
      f4[ind] = formant_frequencies[3];
      ind = ind + 1;
    }
    delete [] formant_frequencies;
  }
  fid.close();
  
  return;
}
