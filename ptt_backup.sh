#!/usr/bin/sh

# error code: 
# 1: no input url by argument and stdin. 
# 2: already exit file with same name in `~/web/ptt/` . 
# 3: file do not created. 
# 6: can not cd `~/web/ptt/` . 

error() {
    echo "$1" >&2
    [ $2 ] && exit $2
}

cd ~/web/ptt/ || error 'can not cd `~/web/ptt/`! ' 6

if [ "$1" = "-p" ]
then
    push="./index.sh -p >index.html"
    shift
fi


if [ -z "$1" ]
then read url
else url="$1"
fi


[ -z "$url" ] && error "you need input http url! " 1


file="$( echo $url | sed 's#.*/##' )"

[ -s "$file" ] && error "file alread exist! please rename existed one. " 2


curl -b 'over18=1' "$url" |
    sed -r '
        s#="/([^/])#href="http://www.ptt.cc/\1#
        s#="//images\.ptt\.cc/[^/]+/#="#
        s#="//ajax\.googleapis\.com/ajax/libs/jquery/[^/]+/#="#
        s#src="//#src="http://#g
    ' >"$file"


[ -s "$file" ] || error "file do not created! " 3

echo "http://gholk.github.io/ptt/$file"
$push
exit 

