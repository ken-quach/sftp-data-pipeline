#!/bin/bash

JOB_NAME="inbound_job"
BASE_DIR="/Users/kennethquach/projects/sftp-data-pipeline"
INBOUND_DIR="$BASE_DIR/ftp/inbound"
LOG_DIR="$BASE_DIR/log"
LOG_FILE="$LOG_DIR/inbound_job.log"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
SFTP_HOST="localhost"
SFTP_USER="kennethquach"
SFTP_KEY="$HOME/.ssh/sftp_pipeline_key"
REMOTE_DIR="vendor_sftp/inbound"
FILE_NAME="vendor_customer.csv"
ACTUAL_HEADER=$(head -n 1 "$INBOUND_DIR/$FILE_NAME")
if [ "$ACTUAL_HEADER" != "$Expected_HEADER" ]; then
	echo "ERROR: Invalid CSV header."
	echo "Expected: $EXPECTED_HEADER"
	echo "Received: $ACTUAL_HEADER"
	echo "[$TIMESTAMP] ERROR: Invalid CSV header." >> "$LOG_FILE"
	exit 1
fi

echo "CSV header validation passed"


echo "Starting $JOB_NAME..."
echo "Project Directory: $BASE_DIR"
echo "Inbound Directory: $INBOUND_DIR"

if [ -f "$INBOUND_DIR/$FILE_NAME" ]; then
	echo "Removing existing local files: $FILE_NAME"
	rm "$INBOUND_DIR/$FILE_NAME"
fi

echo "Starting SFTP Transfer..."

sftp -i "$SFTP_KEY" "$SFTP_USER@$SFTP_HOST" <<EOF
cd "$REMOTE_DIR"
lcd "$INBOUND_DIR"
get "$FILE_NAME"
bye
EOF
SFTP_STATUS=$?

if [ "$SFTP_STATUS" -ne 0 ]; then
	echo "ERROR: SFTP transfer failed!"
	echo "[$TIMESTAMP] ERROR: SFTP transfer failed with status $SFTP_STATUS." >> "$LOG_FILE"
	exit 1
fi

if [ -f "$INBOUND_DIR/$FILE_NAME" ]; then
	echo "File found: $FILE_NAME"
	echo "[$TIMESTAMP] SUCCESS: File found: $FILE_NAME" >> "$LOG_FILE"
else
	echo "ERROR: File not found: $FILE_NAME"
	echo "[$TIMESTAMP] ERROR: File not found: $FILE_NAME" >> "$LOG_FILE"
	exit 1
fi

if [ ! -s "$INBOUND_DIR/$FILE_NAME" ]; then
        echo "ERROR: FILE is empty: $FILE_NAME"
        echo "[$TIMESTAMP] ERROR: File is empty: $FILE_NAME" >> "$LOG_FILE"
        exit 1
fi
echo "File is not empty: $FILE_NAME"

echo "Job completed successfully."
echo "[$TIMESTAMP] SUCCESS: $JOB_NAME completed successfully." >> "$LOG_FILE"
exit 0
