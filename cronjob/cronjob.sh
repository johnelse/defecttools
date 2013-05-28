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

# Configuration

# Log location
STDOUT_FILE=/home/ring3defects/logs/ddd_out
# Errorlog location
STDERR_FILE=/home/ring3defects/logs/ddd_err
# Database location
DATA_DIR=/home/ring3defects/data/defect_dashboard
# Webserver directory
#WEB_DIR=/home/ring3defects/public_html
# Current data
DATE=`date +"%d%m%Y"`

# Make a log entry start
printf "===$0 Started at: " | tee -a $STDOUT_FILE $STDERR_FILE
date | tee -a $STDOUT_FILE  $STDERR_FILE

# DDD Project
# Get data from jira and insert in the database
/home/ring3defects/defecttools/defecttools/ddd/retrieve_data >> $STDOUT_FILE 2>> $STDERR_FILE
# Get data from database, compare, calculate, and update wiki
/home/ring3defects/defecttools/defecttools/ddd/update_graphs >> $STDOUT_FILE 2>> $STDERR_FILE

# CW Project
/home/ring3defects/defecttools/defecttools/cw/update_graphs >> $STDOUT_FILE 2>> $STDERR_FILE

# Snapshot the database.
cp $DATA_DIR/tickets.db $DATA_DIR/backups/tickets-${DATE}.db

# Finish log entry end
printf "===$0 Ended at: " | tee -a $STDOUT_FILE $STDERR_FILE
date | tee -a $STDOUT_FILE  $STDERR_FILE