#############################
#
#  This script makes pitch tracks of the requested wav file and allows post-processing of the pitch tracks for smoothing/stylization.
 
#  Currently, only *.wav files are read.  Textgrids are ignored.
#
#  Input parameters include (in this order):
#  Input file, Time step, Minimum Pitch, Maximum Pitch, Silence Threshold,  
#  Voicing Threshold, Octave cost, octave-Jump Cost, Voiced/unvoiced cost, Kill octave jumps, Smooth, Interpolate, Method (ac or cc)
#
#  For each input, it creates a tab delimited text file with
#  measurement results in the same folder.  The file consists
#  of a pitch track created by the cross-correlation method (cc) or autocorrelation method.  Results  are saved as a *.cc or *.ac file
#############################

form Create Pitch Tracks
# kill octave jumps tries to remove pitch halving/doubling 
# smoothing allows smoothing at a given bandwidth in Hz
# interpolation allows interpolation over missing values 
   text wavfile test.wav
   text resultfile test.f0
   text gender M
endform

time_step = 0
silence_threshold = 0.1
voicing_threshold = 0.5
octave_cost = 0.1
octave_jump_cost = 0.5
voiced_unvoiced_cost = 0.25
kill_octave_jumps = 1
smooth = 1
smooth_bandwidth = 5
interpolate = 1

if gender$ = "M"
  minimum_pitch=60
  maximum_pitch=220
else
  minimum_pitch=100
  maximum_pitch=300
endif

# A sound file is opened
Read from file: wavfile$

# Auto-correlation
To Pitch (ac)... 'time_step' 'minimum_pitch' 10 yes 'silence_threshold' 'voicing_threshold' 'octave_cost' 'octave_jump_cost' 'voiced_unvoiced_cost' 'maximum_pitch'


# Postprocessing for smoothing/stylization
if 'kill_octave_jumps' = 1
    Kill octave jumps
endif

# Smooth 
if 'smooth' = 1
    Smooth... smooth_bandwidth
endif

# Interpolate over missing values
if 'interpolate' = 1
    Interpolate
endif

Down to PitchTier

# Write to file	
# resultfile$ = "'resultfile$'.f0"

# Check if the result file exists:
if fileReadable (resultfile$)
	filedelete 'resultfile$'
endif

Write to headerless spreadsheet file... 'resultfile$'
