#!/bin/sh

set -e

usage()
{
    [ -n "$1" ] && echo $1 >&2
    echo "Usage: $0 [-t] [-v] [-r] [-g] [-s <name>] -n <name>" >&2
    echo "  -n  The full name of the new project" >&2
    echo "  -s  The short name of the project; default: camel-cases the full name" >&2
    echo "  -r  Rename all instances of PhoneGap; use with care, as" >&2
    echo "      this will make it very difficult to merge in future updates" >&2
    echo "  -t  Test only; don't actually make any changes" >&2
    echo "  -v  Enable verbose mode" >&2
    echo "  -g  Use git to rename files" >&2
    exit 1
}

appname= shortname= renameall= verbose= usegit= testonly=
while getopts s:n:tvrg ch
do
    case "$ch" in
    n) appname="$OPTARG";;
    s) shortname="$OPTARG";;
    r) renameall=TRUE;;
    g) usegit=TRUE;;
    v) verbose=TRUE;;
    t) testonly=TRUE;;
    *) usage;;
    esac
done
shift $(($OPTIND - 1))

cd iphone

TEST=
CMD=
[ -z "$appname" ] && usage
[ -n "$usegit" ] && CMD=git
[ -n "$testonly" ] && TEST=echo

[ -z "$shortname" ] && shortname=`echo $appname | sed -E -e 's/[^a-zA-Z0-9]//g'`
[ -n "$verbose" ] && echo "Long name:  $appname"
[ -n "$verbose" ] && echo "Short name: $shortname"

[ -d PhoneGap.xcodeproj ] || usage "PhoneGap.xcodeproj doesn't exist"

[ -n "$verbose" ] && set -x

xcodeproj=PhoneGap.xcodeproj/project.pbxproj
$TEST $CMD mv PhoneGap.plist $shortname.plist
$TEST sed -E -i '' -e "s/PhoneGap.plist/$shortname.plist/g"  $xcodeproj
$TEST sed -E -i '' -e "s/PhoneGap.app/$shortname.app/g" $xcodeproj
$TEST sed -E -i '' -e "s/name = PhoneGap/name = \"$appname\"/g" $xcodeproj
$TEST sed -E -i '' -e "s/PRODUCT_NAME = PhoneGap/PRODUCT_NAME = $shortname/g" $xcodeproj
$TEST sed -E -i '' -e "s/productName = PhoneGap/productName = $shortname/g" $xcodeproj
$TEST sed -E -i '' -e "s/PhoneGap Demo/$appname/g" Info.plist
$TEST sed -E -i '' -e "s/PhoneGap/$shortname/g" Info.plist

if [ -n "$renameall" ]; then
    $TEST sed -E -i '' -e "s/PhoneGap/$shortname/g" $xcodeproj
    for file in `find . -type f -name '*.xib' -o -name '*.h' -o -name '*.m' -o -name '*.pch' | grep -v Frameworks`; do
        $TEST sed -E -i '' -e "s/PhoneGap/$shortname/g" $file
        newfilename=`echo $file | sed -e s/PhoneGap/$shortname/`
        if [ $newfilename != $file ]; then
            $TEST $CMD mv "$file" "$newfilename"
        fi
    done
fi

$TEST $CMD mv PhoneGap.xcodeproj $shortname.xcodeproj
