#!/bin/bash

JOB_NAME="outbound_job"
BASE_DIR="/Users/kennethquach/projects/sftp-data-pipeline"
OUTBOUND_DIR="$BASE_DIR/ftp/outbound"

LOG_DIR="$BASE_DIR/log"
LOG_FILE="$LOG_DIR/outbound_job.log"

TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

SFTP_HOST="localhost"
SFTP_USER="kennethquach"
SFTP_KEY="$HOME/.ssh/sftp_pipeline_key"
REMOTE_DIR="vendor_sftp/from_company"

FILE_NAME="customer_export.csv"
echo "Starting $JOB_NAME..."
echo "Outbound Directory: $OUTBOUND_DIR"

if [ ! -f "$OUTBOUND_DIR/$FILE_NAME" ]; then
    echo "ERROR: Outbound file not found: $FILE_NAME"
    echo "[$TIMESTAMP] ERROR: Outbound file not found: $FILE_NAME" >> "$LOG_FILE"
    exit 1
fi

echo "Outbound file found: $FILE_NAME"
echo "Starting SFTP transfer..."

sftp -i "$SFTP_KEY" "$SFTP_USER@$SFTP_HOST" <<EOF
cd "$REMOTE_DIR"
lcd "$OUTBOUND_DIR"
put "$FILE_NAME"
bye
EOF

SFTP_STATUS=$?

if [ "$SFTP_STATUS" -ne 0 ]; then
    echo "ERROR: SFTP transfer failed."
    echo "[$TIMESTAMP] ERROR: SFTP transfer failed with status $SFTP_STATUS." >> "$LOG_FILE"
    exit 1
fi

echo "SFTP transfer completed successfully."
echo "[$TIMESTAMP] SUCCESS: $FILE_NAME transferred successfully." >> "$LOG_FILE"

exit 0
