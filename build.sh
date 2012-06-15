#!/bin/sh
set -ex
NAME=CocoaLumberjack

[ -z $WORKSPACE ] && WORKSPACE=$PWD
INSTALL_PATH=$WORKSPACE/artifacts

TMPDIR=`mktemp -d $WORKSPACE/tmp-${NAME}.XXXXXX` || exit 1

rm -rf $INSTALL_PATH
mkdir -p $INSTALL_PATH

PROJ=$NAME.xcodeproj 

xcodebuild \
    -project $PROJ \
    -sdk iphoneos \
    DSTROOT=$TMPDIR/device \
    PUBLIC_HEADERS_FOLDER_PATH=/Headers \
    SKIP_INSTALL=NO \
    install
xcodebuild \
    -project $PROJ \
    -sdk iphonesimulator \
    DSTROOT=$TMPDIR/simulator \
    PUBLIC_HEADERS_FOLDER_PATH=/Headers \
    SKIP_INSTALL=NO \
    install

lipo -create -output $INSTALL_PATH/lib$NAME.a $TMPDIR/device/usr/local/lib/lib$NAME.a $TMPDIR/simulator/usr/local/lib/lib$NAME.a
mv $TMPDIR/device/Headers $INSTALL_PATH
rm -rf $TMPDIR
(cd $INSTALL_PATH; zip -r ../$NAME.zip lib$NAME.a Headers Bundles)
