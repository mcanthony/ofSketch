#!/bin/bash

# To use:
#
# ./build_distro.sh SYSTEM VERSION 
#
# ./build_distro.sh osx 0.1.1 

if [ $# -ne 2 ]
  then
    echo "SYSTEM and VERSION Arguments required."
    exit 1
fi

# the current build system
SYSTEM=$1

# the current semantic version number
OF_SKETCH_VERSION=$2

# current of version
OF_VERSION="0.8.1"

# make the release file name.
OF_RELEASE="of_v${OF_VERSION}_${SYSTEM}_release"

echo "Building..."
echo "           SYSTEM: ${SYSTEM}"
echo "OF_SKETCH_VERSION: ${OF_SKETCH_VERSION}"
echo "       OF_VERSION: ${OF_VERSION}"

# change from the scripts to the build directory
mkdir ../build/ &> /dev/null
cd ../build/

SUFFIX=""

if [[ $SYSTEM -eq "linux64" ]]
then
 SUFFIX="tar.gz"
else
 SUFFIX="zip"
fi

echo $SUFFIX


# download the required release if needed.
if [[ ! -d $OF_RELEASE ]]; then
	echo "NO ${OF_RELEASE}"
	curl -O "http://www.openframeworks.cc/versions/v${OF_VERSION}/${OF_RELEASE}.${SUFFIX}"
	
if [[ $SYSTEM == "linux64" ]]
then
  tar xvf  ${OF_RELEASE}.${SUFFIX}
else
  unzip ${OF_RELEASE}.${SUFFIX}
fi

fi

# make the distro directory name
DIST="ofSketch_v${OF_SKETCH_VERSION}_${SYSTEM}_release"

# make the directory and pipe errors to /dev/null if it exists
rm -r $DIST/ &> /dev/null

mkdir -p $DIST/data

cd $DIST/data

echo "Copy app data ..."
cp -r ../../../ofSketchApp/bin/data/DocumentRoot .
cp -r ../../../ofSketchApp/bin/data/media .
cp -r ../../../ofSketchApp/bin/data/Projects .
cp -r ../../../ofSketchApp/bin/data/Resources .
cp -r ../../../ofSketchApp/bin/data/ssl .
cp -r ../../../ofSketchApp/bin/data/uploads .

mkdir openFrameworks && cd openFrameworks

echo "Copy thinned openFrameworks distribution ..."

cp -r ../../../$OF_RELEASE/addons .
cp -r ../../../$OF_RELEASE/export . 
cp -r ../../../$OF_RELEASE/libs . 
cp -r ../../../$OF_RELEASE/LICENSE.md . 

echo "Pre-building openFrameworks libs..."

cd libs/openFrameworksCompiled/project

make -s -j10 Release

# back to $DIST folder
cd ../../../../..

echo "Copy app..."

if [[ $SYSTEM -eq "linux64" ]]
then
cp ../../ofSketchApp/bin/ofSketchApp ofSketchApp
else
cp -r ../../ofSketchApp/bin/ofSketchAppDebug.app ofSketch.app
fi



echo "Copy text docs..."
cp ../../CONTRIBUTING.md .
cp ../../LICENSE.md .
cp ../../README.md .
cp ../../CHANGELOG.md .

echo "Cleaning distro..."

cd data/Projects

rm -rf $(find . -name *.app)
rm -rf $(find . -name obj)

cd ../..

rm -rf $(find . -name .git*)
rm -rf $(find . -name .DS_Store)

echo "Making zip..."

cd ..

zip -r $DIST.zip $DIST 
