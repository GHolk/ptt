#!/bin/sh

# error code: 
# 1: invalid url.
# 2: already exist file with same name in `~/web/ptt/` . 
# 3: file do not created. 
# 6: can not cd `~/web/ptt/` . 

queue="ptt_backup_queue.txt"
queue_old="ptt_backup_queue_old.txt"
date="`date -Iseconds`"
ptt_dir="$HOME/web/ptt/backup"

error() {
    echo "$1" >&2
    [ -n "$2" ] && exit $2
}

preserve_url() {
    url="$1"
    echo "$url" "$date" >>"$queue"
}

add_meta() {
    file="$1"
    ./genpttmeta.pl "$file" >>index_new.html
}

curl_sed() {

    url="$1"
    file="$(echo $url | sed 's#.*/##')"

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
            s#="//images\.ptt\.cc/.*/#="#
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

    add_meta "$file"
}

cd $ptt_dir || error 'can not cd `~/web/ptt/`!' 6


exec 6>&1 1>/dev/null # disable expr output. 
if expr "$1" : '^-'
then
    expr "$1" : '.*p' && push="./index.sh -p"
    expr "$1" : '.*f' && overwrite=1
    expr "$1" : '.*q' && preserve=1
    expr "$1" : '.*c' && clean=1 overwrite=1
    shift
fi
exec 1>&6 6>&- # restore output


if [ "$clean" = 1 ] 
then
    exec 5<&0 <"$queue"
    first_line=10
    if expr "$1" : '^[0-9]\+$' >/dev/null 
    then
        first_line="$1"
        shift
    fi

    head -n "$first_line" | tee -a "$queue_old" | cut -d ' ' -f 1 |\
    while read url
    do
        curl_sed "$url"
    done
    exec 0<&5 5<&-
    sed -i "1,$first_line d" "$queue"
fi


if [ "$preserve" = 1 ]
then
    mydo=preserve_url
else
    mydo=curl_sed
fi

if [ -n "$1" ]
then
    $mydo "$1"
else
    if [ "$clean" != 1 ]
    then
        while read url
        do
            $mydo "$url"
        done
    fi
fi

if [ -s "$queue" ]
then
    echo "## url in queue: #######################"
    tail "$queue"
fi

eval $push
exit

