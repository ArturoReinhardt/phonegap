#!/bin/sh

set -e

usage()
{
    [ -n "$1" ] && echo $1 >&2
    echo "Usage: $0 [-r] [-v] [-g] -n <name>" >&2
    echo "  -n  Specify the name of the new project" >&2
    echo "  -r  Rename all instances of PhoneGap; use with care, as" >&2
    echo "      this will make it very difficult to merge in future updates" >&2
    echo "  -v  Enable verbose mode" >&2
    echo "  -g  Use git to rename files" >&2
    exit 1
}

renameall= verbose= usegit= appname=
while getopts :v:n:r:g ch
do
    case "$ch" in
    n) appname="$OPTARG";;
    r) renameall=TRUE;;
    g) usegit=TRUE;;
    v) verbose=TRUE;;
    *) usage;;
    esac
done
shift $(($OPTIND - 1))

cd iphone

CMD=
[ -z "$appname" ] && usage
[ -n "$usegit" ] && CMD=git

shortname=`echo $appname | sed -E -e 's/[^a-zA-Z0-9]//g'`
[ -n "$verbose" ] && echo "Long name:  $appname"
[ -n "$verbose" ] && echo "Short name: $shortname"

[ -d PhoneGap.xcodeproj ] || usage "PhoneGap.xcodeproj doesn't exist"

[ -n "$verbose" ] && set -x

xcodeproj=PhoneGap.xcodeproj/project.pbxproj
$CMD mv PhoneGap.plist $shortname.plist
sed -E -i '' -e "s/PhoneGap.plist/$shortname.plist/g"  $xcodeproj
sed -E -i '' -e "s/PhoneGap.app/$shortname.app/g" $xcodeproj
sed -E -i '' -e "s/name = PhoneGap/name = \"$appname\"/g" $xcodeproj
sed -E -i '' -e "s/PRODUCT_NAME = PhoneGap/PRODUCT_NAME = $shortname/g" $xcodeproj
sed -E -i '' -e "s/productName = PhoneGap/productName = $shortname/g" $xcodeproj
sed -E -i '' -e "s/PhoneGap Demo/$appname/g" Info.plist
sed -E -i '' -e "s/PhoneGap/$shortname/g" Info.plist

if [ -n "$renameall" ]; then
    sed -E -i '' -e "s/PhoneGap/$shortname/g" $xcodeproj
    for file in `find . -type f -name '*.xib' -o -name '*.h' -o -name '*.m' -o -name '*.pch' | grep -v Frameworks`; do
        sed -E -i '' -e "s/PhoneGap/$shortname/g" $file
        newfilename=`echo $file | sed -e s/PhoneGap/$shortname/`
        if [ $newfilename != $file ]; then
            $CMD mv "$file" "$newfilename"
        fi
    done
fi

$CMD mv PhoneGap.xcodeproj $shortname.xcodeproj
