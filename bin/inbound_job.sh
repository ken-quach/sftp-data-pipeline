#!/bin/bash

JOB_NAME="inbound_job"
BASE_DIR="/Users/kennethquach/projects/sftp-data-pipeline"
source "$BASE_DIR/etc/sftp_config.sh"
INBOUND_DIR="$BASE_DIR/ftp/inbound"
LOG_DIR="$BASE_DIR/log"
ARCHIVE_DIR="$BASE_DIR/ftp/archive"
ARCHIVE_TIMESTAMP=$(date "+%Y%m%d_%H%M%S")

LOG_FILE="$LOG_DIR/inbound_job.log"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

FILE_NAME="vendor_customer.csv"

echo "Starting $JOB_NAME..."
echo "Project Directory: $BASE_DIR"
echo "Inbound Directory: $INBOUND_DIR"

if [ -f "$INBOUND_DIR/$FILE_NAME" ]; then
	echo "Removing existing local files: $FILE_NAME"
	rm "$INBOUND_DIR/$FILE_NAME"
fi

echo "Starting SFTP Transfer..."

sftp -i "$SFTP_KEY" "$SFTP_USER@$SFTP_HOST" <<EOF
cd "$REMOTE_INBOUND_DIR"
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
ARCHIVE_FILE="$ARCHIVE_DIR/${ARCHIVE_TIMESTAMP}_$FILE_NAME"

cp "$INBOUND_DIR/$FILE_NAME" "$ARCHIVE_FILE"

if [ $? -ne 0 ]; then
    echo "ERROR: Failed to archive $FILE_NAME"
    echo "[$TIMESTAMP] ERROR: Failed to archive $FILE_NAME" >> "$LOG_FILE"
    exit 1
fi

echo "Archived file: $ARCHIVE_FILE"
echo "[$TIMESTAMP] SUCCESS: Archived $FILE_NAME" >> "$LOG_FILE"

echo "Job completed successfully."
echo "[$TIMESTAMP] SUCCESS: $JOB_NAME completed successfully." >> "$LOG_FILE"
exit 0
