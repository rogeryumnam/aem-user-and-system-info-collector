#!/bin/sh

#######################################################################################
# version 0.1
#
# Revised at 2016/09/01
#
# Edited by Robert Wunsch  wunsch@adobe.com
#
## Version 
#    0.1 : first reelase
# 
# Sample Usage:
# ./aem-user-and-system-info-collector.sh  -u admin -p admin -a http://localhost:4502 
# ./aem-user-and-system-info-collector.sh  -c file-containing-list-of-servers-and-credentials.tsv
#
#
# Credits:
# This script is heavily inspired by the "system-info-collector.sh"-script by Takahito Kikuchi  tkikuchi@adobe.com.
# URL: https://wiki.corp.adobe.com/display/obujpn/Enhanced+System+info+collector
#######################################################################################

function usage() {
		  echo "---------------------"
          echo "Usage: options" 1>&2
		  echo "---------------------"
          echo "-u : user login (default is prompted if online mode)" 1>&2
          echo "-p : password" 1>&2
          echo "-a : server url e.g. http://localhost:4502 (default is prompted if online mode)" 1>&2
		  echo "-c : define server-url (a), login(u), password(p) and servername in tab delimited text-file for batch collection" 1>&2
          echo "-t : take thread dumps" 1>&2
          echo "-d : destination folder/directory (default 'server-info'-folder)" 1>&2
          echo ""
		  echo "---------------------"
          echo "Sample Usage: "
		  echo "---------------------"
          echo "./aem-user-and-system-info-collector.sh  -u admin -p admin -a http://localhost:4502" 1>&2
		  echo ""
		  echo "./aem-user-and-system-info-collector.sh  -c file-containing-list-of-servers-and-credentials.tsv -d ./server_info" 1>&2
          echo "---------------------"
		  exit 1
}


while getopts u:p:a:c:t:d: OPT
do
  case $OPT in
	"u" ) FLG_U="TRUE"  ; VALUE_U="$OPTARG" ;;
	"p" ) FLG_P="TRUE"  ; VALUE_P="$OPTARG" ;;
	"a" ) FLG_A="TRUE"  ; VALUE_A="$OPTARG" ;;
	"c" ) FLG_C="TRUE"  ; VALUE_C="$OPTARG" ;;
	"t" ) FLG_T="TRUE"  ; VALUE_T="$OPTARG" ;;
	"d" ) FLG_D="TRUE"  ; VALUE_D="$OPTARG" ;;
	  * ) usage exit 1 ;;   
  esac
done

if [ "$FLG_U" = "TRUE" ]; then
  USER=$VALUE_U
fi

if [ "$FLG_P" = "TRUE" ]; then
  PASS=$VALUE_P
fi

if [ "$FLG_A" = "TRUE" ]; then
  SERVERURL=$VALUE_A
elif [ "$FLG_C" = "TRUE" ]; then
  CONFIG_FILE=$VALUE_C
else
  usage
fi

if [ "$FLG_D" = "TRUE" ]; then
  DIRECTORY=$VALUE_D
fi

if hash curl 2>/dev/null; then
	echo "CURL installed"
else
	echo "You need to install CURL to continue"
	exit;
fi

# Get 'configuration-status' of server as ZIP
echo "executing: "
echo "	curl -u $USER:$PASSWORD -O -J -P $DIRECTORY -k $SERVERURL/system/console/status-slinglogs/configuration-status.zip"
echo "	-O : Download"
echo "	-J : User File-Name used on Server"
echo "	-d : Folder to save file in"
echo "	-k : allow insecure SSL connections"
curl -u $USER:$PASS -O -J -k $SERVERURL/system/console/status-slinglogs/configuration-status.zip


# Collecting "bundles.json" for use in tools from http://www.aemstuff.com/ -> Tools
curl -u $USER:$PASS -O -J -P $DIRECTORY -k $SERVERURL/system/console/bundles.json