#!/bin/bash
# Script to automatically remove ReMarkable2 entries from your host keys
# Useful for raplidly switching between ReMarkable2 entries if you have multiple devices you are testing on
# JamesR 8-16-24

# Variables

# BUGFIX: I wonder if BSD grep is the issue. On my Mac if I feed it an absolute path,
# I get a file not found, but if I cat that exact path before or after the command,
# it works fine :) im definitely not angry about the time I spent troubleshooting :)

hostsFile="/Users/jrollo/.ssh/known_hosts"
bakFile="/Users/jrollo/.ssh/known_hosts.bak"
tmpFile="/Users/jrollo/.ssh/tmp-hosts"
rM="10.11.99.1"
entryTest=$(cat /Users/jrollo/.ssh/known_hosts | grep -Fxq $rM)

# Perform backup in case I break everything
cp $hostsFile $bakFile

# TODO: test for backup file creation, terminate if it wasn't created
# i aint wanna be responsible for ruining peoples probably critical host keys lol

if [ -z "$bakFile" ] 
then
	echo "    ~~~~~~~WARNING~~~~~~"
	echo "A backup file was not located. We are terminating for safety!!!"
	echo ""
	exit
fi 

# read in file and perform operation
cat $bakFile | sed '/$rM/d' $hostsFile >> $tmpFile

# Remove original file
rm -f $hostsFile

# Restore file from backup
cp $bakFile $hostsFile

# Test to see if lines are removed
echo "Testing to see if lines were removed..."

if grep -Fw "10.11.99.1" $hostsFile
then
	#echo "No results!"
	echo "There are still some ReMarkable entries in your host keys :("
	exit
else
	echo "No results!"
	exit
fi
