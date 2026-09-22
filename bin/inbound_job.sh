#!/bin/bash

JOB_NAME="inbound_job"
BASE_DIR="/Users/kennethquach/projects/sftp-data-pipeline"
INBOUND_DIR="$BASE_DIR/ftp/inbound"
LOG_DIR="$BASE_DIR/log"
LOG_FILE="$LOG_DIR/inbound_job.log"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

FILE_NAME="vendor_customer.csv"

echo "Starting $JOB_NAME..."
echo "Project Directory: $BASE_DIR"
echo "Inbound Directory: $INBOUND_DIR"

if [ -f "$INBOUND_DIR/$FILE_NAME" ]; then
	echo "File found: $FILE_NAME"
	echo "[$TIMESTAMP] SUCCESS: File found: $FILE_NAME" >> "$LOG_FILE"
else
	echo "ERROR: File not found: $FILE_NAME"
	echo "[$TIMESTAMP] ERROR: File not found: $FILE_NAME" >> "$LOG_FILE"
	exit 1
fi
echo "Job completed successfully."
echo "[$TIMESTAMP] SUCCESS: $JOB_NAME completed successfully." >> "$LOG_FILE"
exit 0
