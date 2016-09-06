# aem-user-and-system-info-collector
A tool / shell-script to collect infos from several AEM instances. These infos include users to determine number of users for comliance reasons. It also includes "bundles.xml" to be used on "http://www.aemstuff.com/tools/coi.html".

##Usage: options

-u : user login (default is prompted if online mode)  
-p : password  
-a : server url e.g. http://localhost:4502 (default is prompted if online mode)  
-c : CSV-file: define server-url (-a), servername (-d), login(-u), password(-p)                                                                                                                                                                                          for batch collection
-d : destination folder/directory (default 'server-info'-folder)  
-t : Connection Timeout (default 30sec)  
-v : more verbose output  
-z : ZIP output (files and folders)  

##Sample Usage:

ONE SERVER:  
./aem-user-and-system-info-collector.sh  -v -z -t 10 -u admin -p admin -a http://localhost:4502 -d 'info_localhost_4502'  

MULTIPLE SERVER:  
./aem-user-and-system-info-collector.sh  -v -z -t 10 -c example-list-of-servers.csv -d 'info_all_servers'  

##CSV File - Content

http://localhost:4502,AEM_6.1_Server-Donald,admin,admin  
http://localhost:4504,AEM_5.6.1_Server-Dagobert,username,password  
http://localhost:4506,AEM_6.2_Server-Goofy,wunsch,c3$6gbH+!  

## Version 
	* v1.1 (6-Sep-16) : add timeout parameter and default timeout check 
	* v1.0 (1-Sep-16): first release


## Changelog

9724893 (HEAD -> master, tag: v1.1.0, origin/master, origin/HEAD) small documentation adjustment: '-t 10' moved.  
825f7e2 add a timeout file to server-folder with timeout.  
f2d3f6f add timeout check and timeout parameter.  
f56ada0  add zip parameter. add one more server in example CSV. 
f746044 add zip-ing of files. change read functionality for CSV from 'more' to 'grep' due to last line issues.  
0b62f3f add zip-ing of files. change read functionality for CSV from 'more' to 'grep' due to last line issues.  
80d7ced correct error in Readme.md  
b74f81c correct error in Readme.md  
dab2766 correct error in Readme.md  
b771fdc ad multi-server collection functionality. add sample CSV list.  
397ddc4 dermine AEM version and use to execute functions according to AEM version  
aac60cd dermine AEM version and use to execute functions according to AEM version  
5172aa7 add curl for bundles.json. add curl for users.json  
d3383fd add description to MD-File.  
133e87e first commit. Add first flags and curl command.  
1fad167 Initial commit  
