#!/usr/bin/sh

# error code: 
# 1: invalid url.
# 2: already exist file with same name in `~/web/ptt/` . 
# 3: file do not created. 
# 6: can not cd `~/web/ptt/` . 

error() {
    echo "$1" >&2
    [ -n "$2" ] && exit $2
}

curl_sed() {

    url="$1"
    file="$(echo $url | sed 's#.*/##')"

    if [ -z "$url" ] || [ -z "$file" ]
    then
        error 'invalid url!'
        return 1
    fi

    if [ -s "$file" ] 
    then
        error "file alread exist! please rename existed one. "
        return 2
    fi

    if curl -Ob 'over18=1' "$url"
    then
        sed -i -r '
            s#="/([^/])#href="http://www.ptt.cc/\1#
            s#="//images\.ptt\.cc/[^/]+/#="#
            s#="//ajax\.googleapis\.com/ajax/libs/jquery/[^/]+/#="#
            s#src="//#src="http://#g
        ' "$file"
    else
        error 'invalid url!'
        return 1
    fi

    if [ -s "$file" ] 
    then
        echo "http://gholk.github.io/ptt/$file"
    else
        error "file do not created! "
        return 3
    fi
}

cd ~/web/ptt/ || error 'can not cd `~/web/ptt/`!' 6

if [ "$1" = "-p" ]
then
    push="./index.sh -p >index.html"
    shift
fi


if [ -n "$1" ]
then
    curl_sed "$1"
else
    while read url
    do
        curl_sed "$url"
    done
fi


eval $push
exit

