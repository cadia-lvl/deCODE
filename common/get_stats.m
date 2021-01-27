function out = get_stats(in)
pkg load statistics

% Computes mean, median mean+-std, skewness and kurtosis of an input vector
% format_out = {'mean','median','mean+std','mean-std','skewness','kurtosis'};

out  = [nanmean(in) nanmedian(in) nanmean(in)+nanstd(in) nanmean(in)-nanstd(in) skewness(in) kurtosis(in)];
