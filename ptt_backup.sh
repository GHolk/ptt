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

preserve_url() {
    url="$1"
    echo "$url" >>preserve_list.txt
}

curl_sed() {

    url="$1"
    file="$(echo $url | sed 's#.*/##')"

    overwrite="$2"

    if [ -z "$url" ] || [ -z "$file" ]
    then
        error 'invalid url!'
        return 1
    fi

    if [ -s "$file" ] && [ "$overwrite" != 1 ]
    then
        error "file already exist! please rename existed one. "
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

cd ${HOME}/web/ptt/ || error 'can not cd `~/web/ptt/`!' 6

if expr "$1" : '^-' >/dev/null
then
    expr "$1" : '.*p' >/dev/null && push="./index.sh -p >index.html"
    expr "$1" : '.*f' >/dev/null && overwrite=1
    expr "$1" : '.*n' >/dev/null && preserve=1
    shift
fi


if [ "$presevre" = 1 ]
then
    mydo=preserve_url
else
    mydo=curl_sed
fi

if [ -n "$1" ]
then
    $mydo "$1" "$overwrite"
else
    while read url
    do
        $mydo "$url" "$overwrite"
    done
fi


eval $push
exit

