#!/bin/bash

#######################################################################################
# version 0.1
#
# Revised at 2016/09/01
#
# Edited by Robert Wunsch  wunsch@adobe.com
#
## Version 
#   v1.2 (19-Sep-16): rdeduce user.json query - nodedepth to "2" -due to server returning massive amounts of "notification entries" in the user-node
# 	v1.1 (6-Sep-16): add timeout parameter and default timeout check 
#   v1.0 (1-Sep-16): first release
# 
# Sample Usage:
# -------------
# ONE SERVER:
# ./aem-user-and-system-info-collector.sh  -v -z -t 10 -u admin -p admin -a http://localhost:4502 
# MULTIPLE SERVER:
# ./aem-user-and-system-info-collector.sh  -v -z -t 10 -c file-containing-list-of-servers-and-credentials.csv (serverURL, username, password, serverName)
#
# ToDo:
# -------------
# add CURL option "-connect-timeout
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
	echo "-c : CSV-file: define server-url (-a), servername (-d), login(-u), password(-p)  for batch collection" 1>&2
	echo "-d : destination folder/directory (default 'server-info'-folder)" 1>&2
	echo "-t : Connection Timeout (default 30sec)" 1>&2
	echo "-v : more verbose output" 1>&2
	echo "-z : zip output" 1>&2
	echo ""
	echo "---------------------"
	echo "Sample Usage: "
	echo "---------------------"
	echo "ONE SERVER:"
	echo "./aem-user-and-system-info-collector.sh  -v -z -t 10 -u admin -p admin -a http://localhost:4502 -d 'info_localhost_4502'" 1>&2
	echo ""
	echo "MULTIPLE SERVER:"
	echo "./aem-user-and-system-info-collector.sh  -v -z -t 10 -c example-list-of-servers.csv -d 'info_all_servers'" 1>&2
	echo "---------------------"
	echo ""
	echo "---------------------"
	echo "CSV File - Content"
	echo "---------------------"
	echo "http://localhost:4502,AEM_6.1_Server-Donald,admin,admin"  
	echo "http://localhost:4504,AEM_5.6.1_Server-Dagobert,username,password"
	echo "http://localhost:4506,AEM_6.2_Server-Goofy,wunsch,c3$6gbH+!" 
	echo ""
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
	echo "-------------------------------------------"
	echo "Checking AEM version"
	echo "-------------------------------------------"
	AEM_VERSION=$(curl -u $USER:$PASS -k $CURL_NON_VERBOSE $SERVERURL/system/console/productinfo | grep "Adobe Experience Manager" | awk -F'[()]' 'NR==5 {print substr($2,0,5)}')
	echo "-----------------------------"
	echo "AEM VERSION: " $AEM_VERSION
	echo "-----------------------------"
}

# Get 'configuration-status' of server as ZIP
function curlConfigurationStatus(){
	echo "-------------------------------------------"
	echo "Get 'configuration-status' of server as ZIP"
	echo "-------------------------------------------"
	if [ "$VERBOSE" = true ] ; then		
		echo "executing: "
		echo "	curl -u $USER:$PASSWORD -O -J -k $SERVERURL/system/console/status-slinglogs/configuration-status.zip"
		echo "	-O : Download"
		echo "	-J : User File-Name used on Server"
		echo "	-k : allow insecure SSL connections"
	fi
	curl -u $USER:$PASS -O -J -k $CURL_NON_VERBOSE $SERVERURL"/system/console/status-slinglogs/configuration-status.zip"
}

# Collecting "bundles.json" for use in tools from http://www.aemstuff.com/ -> Tools
function curlBundleJson(){
	echo "-------------------------"
	echo "Collecting 'bundles.json'"
	echo "-------------------------"
	if [ "$VERBOSE" = true ] ; then
		echo "executing: "
		echo "	curl -u $USER:$PASSWORD -O -J -k $SERVERURL/system/console/bundles.json"
		echo "	-O : Download"
		echo "	-J : User File-Name used on Server"
		echo "	-k : allow insecure SSL connections"
	fi
	curl -u $USER:$PASS -O -J -k $CURL_NON_VERBOSE $SERVERURL"/system/console/bundles.json"
}

# Collecting "package_list.xml" for use in CQ Package Analyzer (http://sj1slm902.corp.adobe.com/)
function curlCrxPackages(){
	echo "-------------------------"
	echo "Collecting 'package_list.xml'"
	echo "-------------------------"
	if [ "$VERBOSE" = true ] ; then
		echo "executing: "
		echo "	curl -u $USER:$PASSWORD -k -o $DIRECTORY/package_list.xml $SERVERURL/crx/packmgr/service.jsp?cmd=ls"
		echo "	-o : Download directory"
		echo "	-k : allow insecure SSL connections"
	fi
	curl -u $USER:$PASS -k -o package_list.xml  $CURL_NON_VERBOSE $SERVERURL"/crx/packmgr/service.jsp?cmd=ls"
}


# Collecting "users.json" to be able to determine named-users
function curlUsersJson(){
	echo "-----------------------"
	echo "Collecting 'users.json'"
	echo "-----------------------"
	if [ "$VERBOSE" = true ] ; then
		echo "executing: "
		echo "	curl -u $USER:$PASSWORD -k -o $DIRECTORY/users.json $SERVERURL/bin/querybuilder.json?property=jcr:primaryType&property.value=rep:User&p.limit=-1&p.hits=full&p.nodedepth=5"
		echo "	-o : Download directory"
		echo "	-k : allow insecure SSL connections"
	fi
	curl -u $USER:$PASS -k -o users.json $CURL_NON_VERBOSE $SERVERURL"/bin/querybuilder.json?property=jcr:primaryType&property.value=rep:User&p.limit=-1&p.hits=full&p.nodedepth=2"
}

# Collecting "indexes.json" to be able to check all indexes (Lucene indexes, OAK indexes)
function curlIndexesJson(){
	echo "------------------------"
	echo "Collecting 'indexes.json'"
	echo "------------------------"
	if [ "$VERBOSE" = true ] ; then
		echo "executing: "
		echo "	curl -u $USER:$PASSWORD -o -k $DIRECTORY/indexes.json $SERVERURL/oak:index.tidy.-1.json"
		echo "	-o : Download directory"
		echo "	-k : allow insecure SSL connections"
	fi
	curl -u $USER:$PASS -k -o indexes.json $CURL_NON_VERBOSE $SERVERURL"/oak:index.tidy.-1.json"
}

### Retrive QueryPerformance Statistics (Slow Queries)
function curlGraniteQueryPerformance(){
	echo "------------------------"
	echo "Collecting 'graniteQueryPerfromance.html'"
	echo "------------------------"
	if [ "$VERBOSE" = true ] ; then
		echo "executing: "
		echo "	curl -u $USER:$PASSWORD -s -o -k  $DIRECTORY/graniteQueryPerformance.txt $SERVERURL/libs/granite/operations/content/diagnosis/tool.html/_granite_queryperformance"
		echo "	-s : Does not output error messages"
		echo "	-o : Download directory"
		echo "	-k : allow insecure SSL connections"
	fi
	curl -u $USER:$PASS -s -k -o graniteQueryPerformance.html $CURL_NON_VERBOSE $SERVERURL"/libs/granite/operations/content/diagnosis/tool.html/_granite_queryperformance" 
}

function checkTimeout ()  {
	echo "------------------------"
	echo "Checking for server timeout (set timeout: $TIMEOUT)"
	echo "------------------------"
	CURL_STATUS=$(curl -u $USER:$PASS -s -w %{http_code} --connect-timeout $TIMEOUT -o /dev/null $SERVERURL"/system/console/vmstat")
}

function countdown () {

  for ((i=$1; i > 0;--i)) do
	printf " $i "
	sleep .25
	printf "."
	sleep .25
	printf "."
	sleep .25
	printf "."
	sleep .25
  done
  printf " GO!"
  echo " "
  sleep 1
}

#---------------------------------------------------------
#---------      MAIN PROGRAMM      -----------------------
#---------------------------------------------------------
# clearing screen
clear

# --------------Get Parameters ---------------------------
while getopts u:p:a:c:d:t:vz OPT

do
  case $OPT in
	"u" ) FLG_U="TRUE"  ; VALUE_U="$OPTARG" ;;
	"p" ) FLG_P="TRUE"  ; VALUE_P="$OPTARG" ;;
	"a" ) FLG_A="TRUE"  ; VALUE_A="$OPTARG" ;;
	"c" ) FLG_C="TRUE"  ; VALUE_C="$OPTARG" ;;
	"d" ) FLG_D="TRUE"  ; VALUE_D="$OPTARG" ;;
	"t" ) FLG_T="TRUE"  ; VALUE_T="$OPTARG" ;;
	"v" ) FLG_V="TRUE"  ;;
	"z" ) FLG_Z="TRUE"  ;;
	  * ) usage exit 1 ;;   
  esac
done

# ------------Check command-line parameters -----------
if [ "$FLG_U" = "TRUE" ]; then
  USER=$VALUE_U
fi

if [ "$FLG_P" = "TRUE" ]; then
  PASS=$VALUE_P
fi

if [ "$FLG_A" = "TRUE" ]; then
  SERVERURL=$VALUE_A
  echo "SINGLE SERVER: Querying only single server. "
elif [ "$FLG_C" = "TRUE" ]; then
  CSV_FILE=$VALUE_C
  echo "MULTIPLE SERVERS: Querying several servers by the list provided in '-c' parameter. "
else
  #Display usage message if neither "-a" or "-c" parameter is given
  # if -a is given only one server is queried
  # if -c is given multiple servers are queried
  usage
fi


if [ "$FLG_T" = "TRUE" ]; then
  TIMEOUT=$VALUE_T
else
  TIMEOUT=30
fi

if [ "$FLG_D" = "TRUE" ]; then
  DIRECTORY=$VALUE_D
else
  DIRECTORY="collected-info"
fi

if [ "$FLG_V" = "TRUE" ]; then
  VERBOSE=true
  SCRIPT_VERBOSE="-v"
  echo "OUTPUT: Verbose"
else
  CURL_NON_VERBOSE="-s"
  echo "OUTPUT: Non Verbose"
fi

if [ "$FLG_Z" = "TRUE" ]; then
  ZIP=true
  echo "OUTPUT: ZIP files and folders."
else
  echo "OUTPUT: Do NOT ZIP files and folders."
fi

# ------------ Software checks -------------------
# Check if necessary software is installed and available

# CURL
if hash curl 2>/dev/null; then
	echo "CURL installed"
else
	echo "You need to install CURL to continue"
	exit 1
fi
# SED
if hash sed 2>/dev/null; then
	echo "SED installed"
else
	echo "You need to install SED to continue"
	exit 1
fi
# ZIP
if [ "$ZIP" = true ] ; then
	if hash zip 2>/dev/null ; then
		echo "ZIP installed"
	else
		echo "You need to install ZIP to continue"
		exit 1
	fi
fi
# READ
if hash read 2>/dev/null; then
	echo "READ installed"
else
	echo "You need to install READ to continue"
	exit 1
fi
# GREP
if hash grep 2>/dev/null; then
	echo "GREP installed"
else
	echo "You need to install GREP to continue"
	exit 1
fi
echo "All necessary software installed."
echo "	"

# ------------- MULTI SERVER --------------------------------
# - Iterate through CSV and call this script recursively ----
# -----------------------------------------------------------
if [ "$FLG_C" = "TRUE" ]; then 
	
	BASENAME_ME=`basename "$0"`
	PWD_ME=`pwd`

	mkdir -p $DIRECTORY
	cd $DIRECTORY	
	
	[ ! -f "$PWD_ME/$CSV_FILE" ] && { echo "$CSV_FILE : file not found in path: $PWD_ME"; exit 99; }
	
	LINE=1
	grep "" $PWD_ME/$CSV_FILE | while IFS=',' read -r server_url servername username password
	do
		# clearing screen
		clear
		echo "-----------------------------------------------"
		echo "CSV line $LINE - Querying Server $servername."
		echo "-----------------------------------------------"
		echo "Server URL : $server_url"
		echo "Servername : $servername"
		echo "Username : $username"
		echo "Password : $password"
		echo "-----------------------------------------------"
		echo "Recursively executing: "
		echo "$PWD_ME/$BASENAME_ME $SCRIPT_VERBOSE -t $TIMEOUT -u $server_url -u $username -p $password -a $server_url."
		echo "-----------------------------------------------"
		countdown 5
		
		# Recursively calling this script with Single Server parameters
		($PWD_ME/$BASENAME_ME $SCRIPT_VERBOSE -t $TIMEOUT -u $username -p $password -d $servername -a $server_url )
		
		((LINE++))
	done
	
	cd $PWD_ME
	
	# ZIPing Folder
	if [ "$ZIP" = true ] ; then	
		zip -q -r $DIRECTORY{.zip,}
		rm -rf $DIRECTORY
	fi
	
	exit 0
fi 

# -------- SINGLE SERVER-------------------------
# - Collect all information from one server -----
# -----------------------------------------------

# Create Directory if it does not exist
mkdir -p $DIRECTORY
cd $DIRECTORY

checkTimeout

if [ "$CURL_STATUS" -eq "000" ] ; then
	echo ""
	echo "> Server did not respond within $TIMEOUT seconds. Please check if '$SERVERURL' is available."
	echo ""
	printf "> Continuing ..."
	touch "server_timed_out_$TIMEOUT_sec.txt"
	countdown 5
else

	# This returns AEM_VERSION
	getAemVersion

	# This collects server information
	curlConfigurationStatus
	curlBundleJson
	curlCrxPackages
	curlUsersJson

	# This is only executed if >= AEM6
	if [[ $AEM_VERSION == 6.* ]]; then 
		curlGraniteQueryPerformance
		curlIndexesJson
	fi

	cd - #go back to last dir "cd $OLDPWD"

	# ZIPing Folder
	if [ "$ZIP" = true ] ; then	
		zip -q -r $DIRECTORY{.zip,}
		rm -rf $DIRECTORY
	fi

	echo "-------------------------------------------"
	echo "Information successfully collected."
	echo "-------------------------------------------"
fi
