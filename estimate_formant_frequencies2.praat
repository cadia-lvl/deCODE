form Estimate formant frequencies
  text audio (Input file name)
  text formant (Name of the output file in the Praat Short Text file format)
  text gender (M or F)
endform
  
! Load speech
Read from file: audio$

! formant frequency estimation
if gender$ = "M"
  maximum_formant = 5000
else
  maximum_formant = 5500
endif
To Formant (burg): 0.01, 5, maximum_formant, 0.025, 50

Save as short text file: formant$
