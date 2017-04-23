#!/bin/sh

#head -n 15 index_old.html
#sed -i '/^<body>$/,$d ;  $i<body>' index.html

[ -s index.html ] && mv index.html index_old.html
sed '/^<body>$/ r index_new.html' index_old.html >index.html
rm index_new.html

if [ "$1" = "-p" ]
then

    #exec 1>&6
    exec 1>&2

    if git add . && git commit -m '[new] auto push' && git push
    then
        exit 0
    else 
        echo "can not push to github! " >&2
        exit 5
    fi
fi

