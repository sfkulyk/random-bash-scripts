# decolor 256 POSIX
  sed 's/\x1B\[[0-9;]\{1,\}[A-Za-z]//g'

# decolor all common ANSI escape sequences
  sed 's/\x1B[@A-Z\\\]^_]\|\x1B\[[0-9:;<=>?]*[-!"#$%&'"'"'()*+,.\/]*[][\\@A-Z^_`a-z{|}~]//g'