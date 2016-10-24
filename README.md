# aem-user-and-system-info-collector
A tool / shell-script to collect infos from several AEM instances.  
These infos include an export of all users - to determine number of users for compliance reasons.  
It also includes "bundles.xml" to be used on "http://www.aemstuff.com/tools/coi.html" to compare bundles against the default ones in vanilla AEM.


##Usage: options

-u : user login (default is prompted if online mode)  
-p : password  
-a : server url e.g. http://localhost:4502 (default is prompted if online mode)  
-c : CSV-file: define server-url (-a), servername (-d), login(-u), password(-p)                                                                                                                                                                                          for batch collection
-d : destination folder/directory (default 'server-info'-folder)  
-t : Connection Timeout (default 30sec)  
-v : more verbose output  
-z : ZIP output (files and folders) 
-n : only query users and creates 'all_users.csv' in folder 'users' 


##Sample Usage:

ONE SERVER:  
./aem-user-and-system-info-collector.sh  -v -z -t 10 -u admin -p admin -a http://localhost:4502 -d 'info_localhost_4502'  

MULTIPLE SERVER:  
./aem-user-and-system-info-collector.sh  -v -z -t 10 -c example-list-of-servers.csv -d 'info_all_servers'  

MULTIPLE SERVER - USERS ONLY: 
./aem-user-and-system-info-collector.sh  -n -v -z -t 10 -c example-list-of-servers.csv -d 'info_all_servers'  


##CSV File - Content

http://localhost:4502,AEM_6.1_Server-Donald,admin,admin  
http://localhost:4504,AEM_5.6.1_Server-Dagobert,username,password  
http://localhost:4506,AEM_6.2_Server-Goofy,wunsch,c3$6gbH+!  


## Version 
	* v1.4 (24-Oct-16) : Adding the parameter 'n', which only queries user and created a CSV and XLS file from all servers combined
	* v1.3 (23-Sep-16) : Removing '-J' in CURL commands due to this not being available at a client version of CURL
	* v1.2 (19-Sep-16): reduce user.json query - nodedepth to "2" -due to server returning massive amounts of "notification entries" in the user-node
	* v1.1 (6-Sep-16) : add timeout parameter and default timeout check 
	* v1.0 (1-Sep-16): first release


## Changelog

* 294cb99 2016-09-23 | updating Readme.md changelog with line ending spaces (HEAD -> master, origin/master, origin/HEAD) [Robert Wunsch]
* 9aa2ba2 2016-09-23 | updating changelog [Robert Wunsch]
* 1c2ede2 2016-09-23 | update gitignore [U-ADOBENET\wunsch]
* 1476c9a 2016-09-23 | v1.3 - readme update [U-ADOBENET\wunsch]
* 7704b23 2016-09-23 | v1.3 (23-Sep-16) : Removing '-J' in CURL commands due to this not being available at a client version of CURL (tag: v1.3) [Robert Wunsch]
* b9c5e39 2016-09-19 | reduce user.json query - nodedepth to '2' -due to server returning massive amounts of 'notification entries' in the user-node (tag: v1.2) [U-ADOBENET\wunsch]
* 13b1925 2016-09-06 | add timeout parameter and default timeout check - tag: v1.1.0 [Robert Wunsch]
* 9724893 2016-09-05 | small documentation adjustment: '-t 10' moved. (tag: v1.1.0) [Robert Wunsch]
* 825f7e2 2016-09-05 | add a timeout file to server-folder with timeout. [Robert Wunsch]
* f2d3f6f 2016-09-05 | add timeout check and timeout parameter. [Robert Wunsch]
* f56ada0 2016-09-04 |  add zip parameter. add one more server in example CSV. [Robert Wunsch]
* f746044 2016-09-04 | add zip-ing of files. change read functionality for CSV from 'more' to 'grep' due to last line issues. [U-ADOBENET\wunsch]
* 0b62f3f 2016-09-04 | add zip-ing of files. change read functionality for CSV from 'more' to 'grep' due to last line issues. [U-ADOBENET\wunsch]
* 80d7ced 2016-09-04 | correct error in Readme.md [Robert Wunsch]
* b74f81c 2016-09-04 | correct error in Readme.md [Robert Wunsch]
* dab2766 2016-09-04 | correct error in Readme.md [Robert Wunsch]
* b771fdc 2016-09-04 | ad multi-server collection functionality. add sample CSV list. [Robert Wunsch]
* 397ddc4 2016-09-03 | dermine AEM version and use to execute functions according to AEM version [Robert Wunsch]
* aac60cd 2016-09-03 | dermine AEM version and use to execute functions according to AEM version [Robert Wunsch]
* 5172aa7 2016-09-03 | add curl for bundles.json. add curl for users.json [Robert Wunsch]
* d3383fd 2016-09-02 | add description to MD-File. [Robert Wunsch]
* 133e87e 2016-09-02 | first commit. Add first flags and curl command. [Robert Wunsch]
* 1fad167 2016-09-02 | Initial commit [Robert Wunsch]


