#!/usr/bin/bash

head -n 15 index_old.html
#sed -i '/^<body>$/,$d ;  $i<body>' index.html

ls -t *.html |\
	sed '/^index.*html$/d' |\
	xargs -d "\n" perl genpttmeta.pl

if [ "$1" == "-p" ]
then

	exec 1>&6

	if git add . && git commit && git push
	then exit 0
	else 
		echo "can not push to github! " >&2
		exit 5
	fi

fi
