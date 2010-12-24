#!/bin/sh
# tmux-open-url - open last URL in current tmux pane in firefox

LAST_URL=$(tmux capture-pane \; show-buffer -b0 \; delete-buffer -b0 |
           grep -P -o '(?:https?://|ftp://|news://|mailto:|file://|\bwww\.)[a-zA-Z0-9\-\@;\/?:&=%\$_.+!*\x27,~#]*(\([a-zA-Z0-9\-\@;\/?:&=%\$_.+!*\x27,~#]*\)|[a-zA-Z0-9\-\@;\/?:&=%\$_+*~])+' |
           tail -1)
[ -n "$LAST_URL" ] && firefox "$LAST_URL"
