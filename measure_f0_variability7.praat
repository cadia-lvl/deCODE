form Measure F0 variability
  text audio (Input file name)
endform
  
! Load speech
Read from file: audio$

! F0 variability measurement
To Pitch: 0.0, 75, 600
plusObject: 1
To PointProcess (cc)
Get jitter (ppq5): 0.0, 0.0, 0.0001, 0.02, 1.3
