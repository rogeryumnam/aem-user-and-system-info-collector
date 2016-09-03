# aem-user-and-system-info-collector
A tool / shell-script to collect infos from several AEM instances. These infos include users to determine number of users for comliance reasons. It also includes "bundles.xml" to be used on "http://www.aemstuff.com/tools/coi.html".

##Usage: options

-u : user login (default is prompted if online mode)  
-p : password  
-a : server url e.g. http://localhost:4502 (default is prompted if online mode)  
-c : CSV-file: define server-url (-a), servername (-d), login(-u), password(-p)                                                                                                                                                                                                 for batch collection
-d : destination folder/directory (default 'server-info'-folder)  
-v : more verbose output)  

##Sample Usage:

ONE SERVER:  
./aem-user-and-system-info-collector.sh  -v -u admin -p admin -a http://localhost:4502 -d 'info_localhost_4502'  

MULTIPLE SERVER:  
./aem-user-and-system-info-collector.sh  -v -c example-list-of-servers.csv -d 'info_all_servers'  

##CSV File - Content

http://localhost:4502,AEM_6.1_Server-Donald,admin,admin  
http://localhost:4504,AEM_5.6.1_Server-Dagobert,username,password  

