# 
# Copyright (c) 2006-2012 XenSource, Inc. All use and distribution of this
# copyrighted material is governed by and subject to terms and
# conditions as licensed by XenSource, Inc. All other rights reserved.
#

import getpass
import os
import sys

config_file = ".defects.rc"

jira_url       = None
confluence_url = None
username       = None
password       = None
database       = None

def load_config():
    global jira_url, confluence_url, username, password, database
    if None in [jira_url, confluence_url, username, password]:
        user = getpass.getuser()
        homedir = os.path.expanduser("~" + user)
        filename = os.path.join(homedir, config_file)
        try:
            f = open(filename)
            try:
                for line in f:
                    pair = line.split("=")
                    if len(pair) == 2:
                        key  = pair[0]
                        value = pair[1][0:-1]
                        if (jira_url is None) and (key == "jira_url"):
                            jira_url = value
                        elif (confluence_url is None) and (key == "confluence_url"):
                            confluence_url = value
                        elif (username is None) and (key == "username"):
                            username = value
                        elif (password is None) and (key == "password"):
                            password = value
                        elif (database is None) and (key == "database"):
                            database = value
            finally:
                f.close()
        except:
            sys.stderr.write("Could not access the configuration file.\n")
            sys.exit(3)

