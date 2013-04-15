STDOUT_FILE=/home/ring3defects/logs/ddd_out
STDERR_FILE=/home/ring3defects/logs/ddd_err

printf "===$0 Started at: " | tee -a $STDOUT_FILE $STDERR_FILE
date | tee -a $STDOUT_FILE  $STDERR_FILE


/home/ring3defects/defecttools/scripts/retrieve_data >> $STDOUT_FILE 2>> $STDERR_FILE
/home/ring3defects/defecttools/scripts/update_graphs >> $STDOUT_FILE 2>> $STDERR_FILE

DATA_DIR=/home/ring3defects/data/defect_dashboard
WEB_DIR=/home/ring3defects/public_html
DATE=`date +"%d%m%Y"`

# Snapshot the database.
cp $DATA_DIR/tickets.db $DATA_DIR/backups/tickets-${DATE}.db
# Copy the database to the directory being served over HTTP.
#cp -f $DATA_DIR/tickets.db $WEB_DIR/db
# Copy the new snapshot to the NFS mount.
#rsync $DATA_DIR/backups/* /mnt/ermintrude/backups

printf "===$0 Ended at: " | tee -a $STDOUT_FILE $STDERR_FILE
date | tee -a $STDOUT_FILE  $STDERR_FILE

