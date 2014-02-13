#
# Copyright (C) Citrix Systems Inc.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published
# by the Free Software Foundation; version 2.1 only. with the special
# exception on linking described in file LICENSE.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Lesser General Public License for more details.

import getpass
import imp
import os
import sys

config_file = ".defecttools/config.py"

expected_keys = [
    "jira_url",
    "jira_username",
    "jira_password",
    "confluence_url",
    "confluence_username",
    "confluence_password",
    "tracker_url",
    "database",
    "db_port",
    "db_host"
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
