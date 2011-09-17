#!/bin/sh
# com - compile anything

#% echo TEST % # %% ## %%% ### %%%% #### % #

# Ported from C code by Tom Duff at http://www.iq0.com/duffgram/com.c:
#
#   looks for the sequence /*% in each file, and sends the rest of the
#   line off to the shell, after replacing any instances of a `%' character
#   with the filename, and any instances of `#' with the filename with its
#   suffix removed.  Used to allow information about how to compile a program
#   to be stored with the program.  The -n flag causes com not to
#   act, but to print out the action it would have taken.
#
# Public domain, 26mar2011  +chris+

CMD=sh
if [ "$1" = "-n" ]; then
  CMD=cat
  shift
fi

if [ $# -eq 0 ]; then
  if [ -r .comfile ]; then
    set - $(cat .comfile)
  else
    echo "Usage: $0 [-n] [FILE...]" >/dev/stderr
    exit 1
  fi
elif [ $CMD = sh ]; then
  echo "$@" >.comfile
fi

for file; do
  sed -n "/\/\*%\|\#%/ {
    s:/\*% *\|#% *::g;
    s:%%:XxXxX:g; s:%:${file}:g;    s:XxXxX:%:g;
    s:##:XxXxX:g; s:#:${file%.*}:g; s:XxXxX:#:g;
    p;q
  }" $file |$CMD
done