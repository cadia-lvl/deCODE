function extended = wextend(input, extension_factor)

input = input(:);
if mod( length(input), 2 ) % the signal length is odd
  input = [input;input(end)];
end
length_input = length(input);

if mod( extension_factor, 2 ) % the extension factor is odd
  extended = repmat(input, extension_factor, 1);
else % the extension factor is even
  extended = zeros(length_input*extension_factor, 1);
  extended(1:length_input/2) = input(length_input/2+1:end);
  extended(length_input/2+1:end-length_input/2) = ...
      repmat(input, extension_factor-1, 1);
  extended(end-length_input/2+1:end) = input(1:length_input/2);
end
