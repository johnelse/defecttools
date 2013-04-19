# Defecttools                                                                                                                                                                                                                      
Python scripts to convert jira bugs into confluence metrics. Calculate defect counts and daily defect inflow/outflow; add this to the confluence wiki. 
                                                                                                                                                                                                                                                                                                                                                                                           
## Installation & configuration  

### Setup Linux (Guide: Ubuntu 12.10 Server)                                                                                                                                                                                                                    
                                                                                                                                                                                                                              
- Install linux distribution of choice
- Update machine (`[sudo] apt-get update & [sudo] apt-get upgrade`)                                                                                                                     
- Install sqlite (`[sudo] apt-get install sqlite3`) 
- Install git (`[sudo] apt-get install git`)                                                                  
- Install pip (`[sudo] apt-get install python-pip`)                                                           
- Install jira-python (`[sudo] pip install jira-python`)
- Fix a bug with latest request (for more info: https://bitbucket.org/bspeakmon/jira-python/issue/9/jira-python-package-does-not-work-with-the). Uninstall latest version and install previous version `[sudo] pip uninstall requests`
`[sudo] pip install requests==0.14.1`

### Git

- Git clone this project onto your server `git clone git@github.com:johnelse/defecttools.git`

### Sqlite (Guide: .filters account)

- Create a folder in the home directory to store the database `mkdir ~/data/defect_dashboard`
- Inside this folder create a folder backups `mkdir ~/data/defect_dashboard/backups`
- Run sqlite3 with tickets.db `sqlite3 tickets.db`
- Create the following structure:
`CREATE TABLE filters(id integer primary key, name text not null, team_id integer, filter_id integer);                                                                                                        
CREATE TABLE tickets(id string primary key, disposition text);                            
CREATE TABLE observations(filter_id integer not null, ticket string not null, time real not null);                                                  CREATE TABLE teams (id integer primary key not null, name string);                             
CREATE UNIQUE INDEX fid on filters(id);`
- [Optional] Export the old data into the new database (see data/source on server for the old import files).

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

- Update the crontab file with the following `0 7 * * * PYTHONPATH=/home/my_user_name; export PYTHONPATH; /home/my_user_name/path/to/cronjob/cronjob.sh`

Sit back and enjoy!

## TODO

- integration with MongoDB  








