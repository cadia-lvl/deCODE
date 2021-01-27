#include <stdio.h>

double string_to_number(const char *string) {
  double value;

  sscanf(string, "%lf", &value);

  return value;
}
