#!/bin/bash

### This shell script takes name of the file and string to write to it.

fileName=$1
strToWrite=$2

if [ $# -lt 2 ]; then
	echo "Insufficient arguments specified"
	exit 1
else
	if [ ! -f $fileName ]
	then
		dirName=$(dirname $fileName)

		if [ ! -d $dirName ]
		then
			echo "Directory does not exist. Creating!!"
			mkdir -p $dirName
		fi
		echo "$fileName does not exists. Creating it"
		touch $fileName
	fi
	
	echo $strToWrite > $fileName
fi
