#!/bin/sh

#head -n 15 index_old.html
#sed -i '/^<body>$/,$d ;  $i<body>' index.html

ex atom.xml <<EOF
0/<updated>/
s/>.*</>$(date -Is)</
0/<generator/
r atom_new.xml
wq
EOF
rm atom_new.xml

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

