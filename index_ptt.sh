#!/usr/bin/bash

if cd ~/web/ptt
then : 
else 
	echo 'can not cd `~/web/ptt`. ' >&2
	exit 4
fi

mv index.html index_old.html
head -n 15 index_old.html >index.html
#sed -i '/^<body>$/,$d ;  $i<body>' index.html
ls -t *.html |\
	sed '/^index.*html$/d' |\
	xargs -d "\n" perl genpttmeta.pl >>index.html

if [ "$1" == "-p" ]
then
	if git add . && git commit && git push
	then exit 0
	else 
		echo "can not push to github! " >&2
		exit 5
	fi
fi
