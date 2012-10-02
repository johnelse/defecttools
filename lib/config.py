# 
# Copyright (c) 2006-2012 XenSource, Inc. All use and distribution of this
# copyrighted material is governed by and subject to terms and
# conditions as licensed by XenSource, Inc. All other rights reserved.
#

import getpass
import imp
import os
import sys

config_file = ".defecttools/config.py"

expected_keys = [
    # Jira.
    "jira_url",
    "jira_username",
    "jira_password",
    # Confluence.
    "confluence_url",
    "confluence_username",
    "confluence_password",
    # IRC.
    "irc_server",
    "irc_port",
    "irc_password",
    "irc_nick",
    "irc_channel",
    # Misc.
    "database"
    ]

def get_config():
    user = getpass.getuser()
    home_dir = os.path.expanduser("~" + user)
    config_path = os.path.join(home_dir, config_file)
    try:
        config = imp.load_source("config", config_path)
        for key in expected_keys:
            config.__getattribute__(key)
        return config
    except IOError:
        raise RuntimeError("No config file found at %s." % config_path)
    except SyntaxError:
        raise RuntimeError("Could not parse config file.")
    except AttributeError as e:
        raise RuntimeError("Missing config key: %s" % e.args[0])
