#!/bin/sh

marketIds="3072,3074,3075,3079,3084,3085,3086,3089,3091,3093,3111,3077,3078,3097,1003,3103,3098,3096"
version="4.3.1"
projectDir=/Volumes/Work/SohuNews/trunk/sohunews
targetName="sohunews"
schema="AdHoc"
distDir=~/market/$targetName/$version
codeSignIdentity="iPhone Distribution: Sohu.com Inc. (NASDAQ: SOHU)"
provisioning="newspaper_adhoc"

mp=~/Nutstore/provision/$provisioning.mobileprovision

uuid=`grep UUID -A1 -a $mp | grep -o "[-A-Z0-9]\{36\}"`
cp $mp ~/Library/MobileDevice/Provisioning\ Profiles/$uuid.mobileprovision

rm -rdf "$distDir"
mkdir -p "$distDir"

baseIpaName="${targetName}_${version}"
echo "pakage base ipa $baseIpaName.ipa..."
cd $projectDir
ruby ~/Nutstore/provision/xcodearchive.rb -m "$uuid" -i "$codeSignIdentity" -o "$distDir" -f $baseIpaName -e $schema -v -c

cd $distDir
unzip "${baseIpaName}.ipa"

for marketId in `echo ${marketIds//,/ }`
do
	ipaName="${targetName}_${version}_${marketId}"
	cd Payload  
	cd "$targetName.app"
	echo "$marketId" > market.id 
	cd ../..  
	zip -r "${ipaName}.ipa" Payload  
	echo "pakage $ipaName.ipa done, in folder: $distDir"
done

echo "opening folder: $distDir"
open $distDir
