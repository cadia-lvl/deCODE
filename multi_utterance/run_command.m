#! /usr/bin/octave -q

usage_msg = 'Usage: ~/prog/run_command.m COMMAND [options]';

if ~nargin
  disp(usage_msg)
  return
end

list = {};
arg_list = argv();
ind_arg = 1;
while ind_arg <= nargin,
  switch arg_list{ind_arg}
    case {'-h', '--help', '-?'}
      disp(usage_msg)
      disp('')
      disp('Options:')
      disp('')
      disp('  -h, -?, --help          Print this message.')
      disp('')
      disp('  COMMAND                 Name of the Matlab command.')
      disp('')
      disp('  any other option        Passed down to COMMAND.')
      disp('')
      return
    otherwise
      list = [list arg_list(ind_arg)];
  end
  ind_arg = ind_arg + 1;
end
if isempty(list)
  error('Command name must be specified!')
end

feval(list{:});
