# Defecttools                                                                                                                                                                                                                      
Python scripts to convert jira bugs into confluence metrics.   

## Usage

                                                                                                                                                                  
                                                                                                                                                                                                                                   
## Installation & configuration  

### Setup Linux (Guide: Ubuntu 12.10 Server)                                                                                                                                                                                                                    
                                                                                                                                                                                                                              
- Install linux distribution of choice
- Update machine (`[sudo] apt-get update & [sudo] apt-get upgrade`)                                                                                                                     
- Install sqlite (`[sudo] apt-get install sqlite3`) 
- Install git (`[sudo] apt-get install git`)                                                                  
- Install pip (`[sudo] apt-get install python-pip`)                                                           
- Install jira-python (`[sudo] pip install jira-python`)

- Set python path `export PYTHONPATH=/home/my_username/`
**NOTE MAKE PERMANENT**

- Fix a bug with latest request (for more info: https://bitbucket.org/bspeakmon/jira-python/issue/9/jira-python-package-does-not-work-with-the). Uninstall latest version and install previous version `[sudo] pip uninstall requests`
`[sudo] pip install requests==0.14.1`

### Git

- Git clone this project onto your server `git clone git@github.com:johnelse/defecttools.git`
- Change into the defect tools folder `cd defect tools`
- git clone the jiralib `git clone git://github.com/xen-org/jiralib.git`

### Sqlite (Guide: .filters account)

- Create a folder in the home directory to store the database `mkdir ~/data/defect_dashboard`
- Inside this folder create a folder backups `mkdir ~/data/defect_dashboard/backups`
- Run sqlite3 with tickets.db `sqlite3 tickets.db`
- Create the following structure:
`CREATE TABLE filters(id integer primary key, name text not null, team_id integer, filter_id integer);                                                                                                        
CREATE TABLE tickets(id string primary key, disposition text);                            
CREATE TABLE observations(filter_id integer not null, ticket string not null, time real not null);                                                  CREATE TABLE teams (id integer primary key not null, name string);                             
CREATE UNIQUE INDEX fid on filters(id);`
- Insert filters
`INSERT INTO filters VALUES(0,'DDD - Ring 3 Tampa Outgoing',0,16815);
INSERT INTO filters VALUES(1,'DDD - Ring 3 Triage',0,16764);
INSERT INTO filters VALUES(2,'DDD - Ring 3 Trunk',0,16799);
INSERT INTO filters VALUES(3,'DDD - Ring 3 Clearwater',0,16766);
INSERT INTO filters VALUES(4,'DDD - Ring 3 Tallahassee',0,16818);
INSERT INTO filters VALUES(5,'DDD - Ring 3 Sarasota',0,16765);
INSERT INTO filters VALUES(6,'DDD - Storage Tampa Outgoing',1,16795);
INSERT INTO filters VALUES(7,'DDD - Storage Triage',1,16794);
INSERT INTO filters VALUES(8,'DDD - Storage Trunk',1,16793);
INSERT INTO filters VALUES(9,'DDD - Storage Clearwater',1,16798);
INSERT INTO filters VALUES(10,'DDD - Storage Tallahassee',1,16796);
INSERT INTO filters VALUES(11,'DDD - Storage Sarasota',1,16797);
INSERT INTO filters VALUES(12,'DDD - Ring 0 Tampa Outgoing',2,16768);
INSERT INTO filters VALUES(13,'DDD - Ring 0 Triage',2,16814);
INSERT INTO filters VALUES(14,'DDD - Ring 0 Trunk',2,16767);
INSERT INTO filters VALUES(15,'DDD - Ring 0 Clearwater',2,16801);
INSERT INTO filters VALUES(16,'DDD - Ring 0 Tallahassee',2,16769);
INSERT INTO filters VALUES(17,'DDD - Ring 0 Sarasota',2,16800);
INSERT INTO filters VALUES(18,'DDD - Windows Tampa Outgoing',3,16789);
INSERT INTO filters VALUES(19,'DDD - Windows Triage',3,16788);
INSERT INTO filters VALUES(20,'DDD - Windows Trunk',3,16787);
INSERT INTO filters VALUES(21,'DDD - Windows Clearwater',3,16792);
INSERT INTO filters VALUES(22,'DDD - Windows Tallahassee',3,16790);
INSERT INTO filters VALUES(23,'DDD - Windows Sarasota',3,16791);
INSERT INTO filters VALUES(24,'DDD - XenCenter Tampa Outgoing',4,16778);
INSERT INTO filters VALUES(25,'DDD - XenCenter Triage',4,16777);
INSERT INTO filters VALUES(26,'DDD - XenCenter Trunk',4,16776);
INSERT INTO filters VALUES(27,'DDD - XenCenter Clearwater',4,16781);
INSERT INTO filters VALUES(28,'DDD - XenCenter Tallahassee',4,16779);
INSERT INTO filters VALUES(29,'DDD - XenCenter Sarasota',4,16780);
INSERT INTO filters VALUES(30,'DDD - WLB Tampa Outgoing',5,16816);
INSERT INTO filters VALUES(31,'DDD - WLB Triage',5,16783);
INSERT INTO filters VALUES(32,'DDD - WLB Trunk',5,16782);
INSERT INTO filters VALUES(33,'DDD - WLB Clearwater',5,16786);
INSERT INTO filters VALUES(34,'DDD - WLB Tallahassee',5,16784);
INSERT INTO filters VALUES(35,'DDD - WLB Sarasota',5,16785);
INSERT INTO filters VALUES(36,'DDD - XenConvert Tampa Outgoing',6,16772);
INSERT INTO filters VALUES(37,'DDD - XenConvert Triage',6,16771);
INSERT INTO filters VALUES(38,'DDD - XenConvert Trunk',6,16770);
INSERT INTO filters VALUES(39,'DDD - XenConvert Clearwater',6,16775);
INSERT INTO filters VALUES(40,'DDD - XenConvert Tallahassee',6,16773);
INSERT INTO filters VALUES(41,'DDD - XenConvert Sarasota',6,16774);
INSERT INTO filters VALUES(42,'DDD - QA Tampa Outgoing',7,16804);
INSERT INTO filters VALUES(43,'DDD - QA Triage',7,16803);
INSERT INTO filters VALUES(44,'DDD - QA Trunk',7,16802);
INSERT INTO filters VALUES(45,'DDD - QA Clearwater',7,16807);
INSERT INTO filters VALUES(46,'DDD - QA Tallahassee',7,16805);
INSERT INTO filters VALUES(47,'DDD - QA Sarasota',7,16806);
INSERT INTO filters VALUES(48,'DDD - All Dev Tampa Outgoing',8,16810);
INSERT INTO filters VALUES(49,'DDD - All Dev Triage',8,16809);
INSERT INTO filters VALUES(50,'DDD - All Dev Trunk',8,16808);
INSERT INTO filters VALUES(51,'DDD - All Dev Clearwater',8,16813);
INSERT INTO filters VALUES(52,'DDD - All Dev Tallahassee',8,16811);
INSERT INTO filters VALUES(53,'DDD - All Dev Sarasota',8,16812);`


### Configuration

- Make a new directory `mkdir ~/.defecttools`
- Copy config.py.example into the new directory `cp config.py.example ~/.defecttools/config.py`
- Update config.py with your credentials
- Remove original config.py.example

### Logs

- Make a new directory logs `mkdir ~/logs`
- Create a general log file `touch ddd_out`
- Create a error log file `touch ddd_err`

### Cronjob

- Install cronjob tool
- Setup the tool to use the cronjob/cronjob.sh









