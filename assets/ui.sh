#!/bin/sh
#remove non-retina images

cd ./../resources/themes;
find . -name "*@ios7@2x.*" -type f | grep -v svn | while read line;

do
    echo ${line} | sed 's/@ios7@2x/''/g' | xargs rm -f {} #删除一倍
    echo ${line} | sed 's/@ios7@2x/@2x/g' | xargs rm -f {} #删除二倍
    mv -fv ${line} `echo ${line} | sed 's/@ios7@2x/@2x/g'` #@ios7@2x to @2x
done