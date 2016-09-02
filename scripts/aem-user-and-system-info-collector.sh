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

# Getting AEM version name
function getAemVersion(){
	# curl -u $USER:$PASS -k $SERVERURL/system/console/productinfo  
	#	->  gets html with AEM version included
	# grep "Adobe Experience Manager"  
	#	-> returns only lines with "AEM" included
	# awk -F'[()]' 'NR==5 {print $2}'  
	#	-> gets text between round braces (version-numbers). There are two round braces, one is the license version number, the other the software version number.
	#	-> due to removal of text we need to use "NR==5" (fifth line) to get the software version number.
	AEM_VERSION=$(curl -u $USER:$PASS -k $SERVERURL/system/console/productinfo | grep "Adobe Experience Manager" | awk -F'[()]' 'NR==5 {print substr($2,0,5)}')
	echo "-----------------------------"
	echo "AEM VERSION: " $AEM_VERSION
	echo "-----------------------------"
}

# Get 'configuration-status' of server as ZIP
function curlConfigurationStatus(){
	echo "-------------------------------------------"
	echo "Get 'configuration-status' of server as ZIP"
	echo "-------------------------------------------"
	echo "executing: "
	echo "	curl -u $USER:$PASSWORD -O -J -k $DIRECTORY -k $SERVERURL/system/console/status-slinglogs/configuration-status.zip"
	echo "	-O : Download"
	echo "	-J : User File-Name used on Server"
	echo "	-k : allow insecure SSL connections"
	mkdir -p $DIRECTORY
	cd $DIRECTORY
	curl -u $USER:$PASS -O -J -k $SERVERURL/system/console/status-slinglogs/configuration-status.zip
	cd - #go back to last dir "cd $OLDPWD"
}

# Collecting "bundles.json" for use in tools from http://www.aemstuff.com/ -> Tools
function curlBundleJson(){
	echo "-------------------------"
	echo "Collecting 'bundles.json'"
	echo "-------------------------"
	echo "executing: "
	echo "	curl -u $USER:$PASSWORD -O -J -k $DIRECTORY -k $SERVERURL/system/console/bundles.json"
	echo "	-O : Download"
	echo "	-J : User File-Name used on Server"
	echo "	-k : allow insecure SSL connections"
	mkdir -p $DIRECTORY
	cd $DIRECTORY
	curl -u $USER:$PASS -O -J -k $SERVERURL/system/console/bundles.json
	cd - #go back to last dir "cd $OLDPWD"
}

# Collecting "users.json" to be able to determine named-users
function curlUsersJson(){
	echo "-----------------------"
	echo "Collecting 'users.json'"
	echo "-----------------------"
	echo "executing: "
	echo "	curl -u $USER:$PASSWORD -k -o $DIRECTORY/users.json $SERVERURL/bin/querybuilder.json?property=jcr:primaryType&property.value=rep:User&p.limit=-1&p.hits=full&p.nodedepth=5"
	echo "	-o : Download directory"
	echo "	-k : allow insecure SSL connections"
	mkdir -p $DIRECTORY
	cd $DIRECTORY
	curl -u $USER:$PASS -k -o users.json $SERVERURL"/bin/querybuilder.json?property=jcr:primaryType&property.value=rep:User&p.limit=-1&p.hits=full&p.nodedepth=5"
	cd - #go back to last dir "cd $OLDPWD"
}

# Collecting "indexes.json" to be able to check all indexes (Lucene indexes, OAK indexes)
function curlIndexesJson(){
	echo "------------------------"
	echo "Collecting 'indexes.json'"
	echo "------------------------"
	echo "executing: "
	echo "	curl -u $USER:$PASSWORD -k -o $DIRECTORY/users.json $SERVERURL/oak:index.tidy.-1.json"
	echo "	-o : Download directory"
	echo "	-k : allow insecure SSL connections"
	mkdir -p $DIRECTORY
	cd $DIRECTORY
	curl -u $USER:$PASS -k -o indexes.json $SERVERURL"/oak:index.tidy.-1.json"
	cd - #go back to last dir "cd $OLDPWD"
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

# returns AEM_VERSION
getAemVersion

curlConfigurationStatus
curlBundleJson
curlUsersJson

if [[ $AEM_VERSION == 6.* ]]; then 
	curlIndexesJson
fi




