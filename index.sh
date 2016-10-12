#!/usr/bin/bash

#head -n 15 index_old.html
#sed -i '/^<body>$/,$d ;  $i<body>' index.html

if [ -s index.html ] ; then
    mv index.html index_old.html
fi

file_list="`ls -t *.html | sed '/^index.*html$/d'`"
file_list="${file_list}
`sed -n '/<a href/ { s/.*<a href="\(.*\)".*/\1/ ; p }' index_old.html`"

echo "$file_list" |\
    sort |\
    uniq -u |\
    xargs -d "\n" perl genpttmeta.pl >index_new.html

sed '/^<body>$/ r index_new.html' index_old.html

if [ "$1" == "-p" ]
then

    #exec 1>&6
    exec 1>&2

    if git add . && git commit -m '[new] auto push' && git push
    then exit 0
    else 
        echo "can not push to github! " >&2
        exit 5
    fi

fi
