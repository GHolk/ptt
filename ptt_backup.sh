#!/usr/bin/bash

# error code: 
# 1: no input url by argument and stdin. 
# 2: already exit file with same name in `~/web/ptt/` . 
# 3: file do not created. 
# 6: can not cd `~/web/ptt/` . 

if cd ~/web/ptt/
then : 
else
	echo 'can not cd `~/web/ptt/`! ' >&2
	exit 6
fi


if [ "$1" == "-p" ]
then
	push="./index_ptt.sh"
	shift
fi


if [ -z "$1" ]
then read url
fi

url="$1"

if [ -z "$url" ]
then
	echo "you need input http url! " >&2
	exit 1
fi


file="${url##*/}"

if [ -s "$file" ]
then
	echo "file alread exist! please rename existed one. " >&2
	exit 2
fi


curl -b 'over18=1' "$url" |
	sed -r 's#href="/([^/])#href="//www.ptt.cc/\1#g ;
		s#"//images\.ptt\.cc/v2\.17/(.*\.css)"#"\1"#g' >"$file"


if [ -s "$file" ]
then
	echo "http://gholk.github.io/ptt/$file"
	$push
	exit 
else
	echo "file do not created! " >&2
	exit 3
fi

