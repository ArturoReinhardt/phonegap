#!/bin/sh
set -x
PHONEGAP_LIB=$TARGET_BUILD_DIR/$CONTENTS_FOLDER_PATH/www/app.js
APPNAME=`defaults read $SOURCE_ROOT/Info CFBundleName`

cd $PROJECT_DIR/..
[ -f Makefile ] && rm Makefile
./configure
make iphone
cp lib/iphone/phonegap-min.js $PHONEGAP_LIB
sed -i '' -e "s/PhoneGap/$APPNAME/g" $PHONEGAP_LIB
