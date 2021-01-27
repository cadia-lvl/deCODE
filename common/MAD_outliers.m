function [y] = MAD_outliers(x);
     
  % Remove outliers using Median Absolute deviation
  x = x(:); 
  ext_x = [median(x);median(x);x;median(x);median(x)];
  thr = 3;
    
  MAD = 1.4826*median(abs(x-median(x)));
  flag = find( ( abs((x-median(x))/MAD)) > thr );
  
  for i = 1:length(flag)
      ind = flag(i);
      x(ind) = mean( [ext_x(ind:ind+1);ext_x(ind+3:ind+4)] );
      
  end
  
  y = x;   
