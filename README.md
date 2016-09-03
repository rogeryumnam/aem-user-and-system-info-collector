# aem-user-and-system-info-collector
A tool / shell-script to collect infos from several AEM instances. These infos include users to determine number of users for comliance reasons. It also includes "bundles.xml" to be used on "http://www.aemstuff.com/tools/coi.html".

##Usage: options

-u : user login (default is prompted if online mode)  
-p : password  
-a : server url e.g. http://localhost:4502 (default is prompted if online mode)  
-c : define server-url (a), login(u), password(p) and servername in tab delimited text-file for batch collection  
-t : take thread dumps  
-d : destination folder (default 'server-info'-folder)  

##Sample Usage:

./aem-user-and-system-info-collector.sh  -u admin -p admin -a http://localhost:4502  

./aem-user-and-system-info-collector.sh  -c file-containing-list-of-servers-and-credentials.tsv -d ./server_info
