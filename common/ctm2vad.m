function out = ctm2vad(sig,ctm)
% Change so that it extracts segments that contain [31,32,33,34]

a = find(ctm(:,3) >= 31 & ctm(:,3) <= 34 );
out = cell;

for i = 1:length(a)
  rr = find( sig > ctm(a(i),1) & sig < ctm(a(i),2) );
  out{i} = sig(rr);
end
