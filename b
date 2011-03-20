#!/bin/sh
# b - trivial commandline browser

STORE="/tmp/b-$HOSTNAME.$USER"

case "$TERM" in
    9term|win) PAGER=cat;;
    *)     PAGER=less; LESS=-FX;;
esac

case "$1" in
    [0-9]*)
        $0 "$(awk '/^References/,0' <$STORE |
              N=$1 awk '$1 == ENVIRON["N"] { print $2 }')";;
    */*|*.*)
        lynx --dump "$1" | tee $STORE | $PAGER;;
    ?*)
        $0 "http://www.google.com/search?ie=utf-8&oe=utf-8&q=$*";;
    *)
        # empty
        $PAGER $STORE 2>/dev/null
esac
