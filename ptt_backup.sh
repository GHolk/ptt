#!/usr/bin/bash

if [ -z "$1" ]
then exit 1
else curl -b 'over18=1' "$1" |
		sed -r 's#href="/([^/])#href="//www.ptt.cc/\1#g' >"${1##*/}"
fi

exit 0
