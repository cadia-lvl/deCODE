function [name,value] = import_ctm(ctm)

%% Main

[fid,~,s,e,phnID] = textread(ctm,'%s %d %f %f %f');

x = 0;
for i = 1:length(fid)
   if s(i) == 0
      x = x+1;
      name{x} = fid{i};
      value{x} = [];
   end
   value{x} = [value{x}; s(i) s(i)+e(i) phnID(i)];
end

[name,ind]=sort(name);
value=value(ind);

