#!/bin/bash
manual_location="TarsosDSP-latest-Manual.pdf"

#Remove old releases
rm -R TarsosDSP-*

#link the source files at the expected locations
cd ..
test -f src || ln -s TarsosDSP/src/main/java/ src
test -f examples || ln -s TarsosDSPExamples/src/main/java/ examples
test -f tests || ln -s TarsosDSP/src/test/java tests 
cd build

#Build the new release
ant release

#Find the current version
filename=$(basename TarsosDSP-*-bin.jar)
version=${filename:10:3}

deploy_dir="/var/www/be.0110/current/public/releases/TarsosDSP/"
deploy_location=$deploy_dir"TarsosDSP-nightly/"

#Build the readme file
textile2html ../README.textile TarsosDSP-$version-Readme.html

#Copy the manual
wget "http://tarsos.0110.be/releases/TarsosDSP/TarsosDSP-latest/TarsosDSP-latest-Manual.pdf"
mv $manual_location TarsosDSP-$version-Manual.pdf


#Remove old nightly version from the server:
ssh joren@0110.be rm -R $deploy_location

ssh joren@0110.be mkdir $deploy_location

#Deploy to the server 
scp -r TarsosDSP-* joren@0110.be:$deploy_location

#Find the current version
filename=$(basename TarsosDSP-*-bin.jar)
version=${filename:10:3}

deploy_dir="/var/www/be.0110/current/public/releases/TarsosDSP/"
deploy_location=$deploy_dir"TarsosDSP-nightly"

ssh joren@0110.be mv $deploy_location/TarsosDSP-$version.jar $deploy_location/TarsosDSP-nightly.jar
ssh joren@0110.be mv $deploy_location/TarsosDSP-$version-bin.jar $deploy_location/TarsosDSP-nightly-bin.jar
ssh joren@0110.be mv $deploy_location/TarsosDSP-$version-Manual.pdf $deploy_location/TarsosDSP-nightly-Manual.pdf
ssh joren@0110.be mv $deploy_location/TarsosDSP-$version-Documentation $deploy_location/TarsosDSP-nightly-Documentation
ssh joren@0110.be mv $deploy_location/TarsosDSP-$version-Readme.html $deploy_location/TarsosDSP-nightly-Readme.html

ssh joren@0110.be rm -r $deploy_location/TarsosDSP-$version-Examples

ssh joren@0110.be mkdir $deploy_location/TarsosDSP-nightly-Examples 

for f in TarsosDSP-$version-Examples/*.jar
do 
        name=`basename $f`
        new_name=${name/$version/nightly}
        scp $f  joren@0110.be:$deploy_location/TarsosDSP-nightly-Examples/$new_name
done