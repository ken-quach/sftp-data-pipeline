# SFTP Data Pipeline

A Bash-based file transfer pipeline that simulates automated data exchange between a company and an external vendor using SFTP.

The project demonstrates Linux/Bash scripting, SSH key authentication, inbound and outbound SFTP transfers, configuration management, file validation, logging, error handling, and file archiving.

## Architecture

### Inbound Flow

Vendor → SFTP GET → Inbound Directory → Validation → Archive → Log

The inbound job:

1. Connects to the vendor SFTP server using SSH key authentication.
2. Downloads a vendor CSV file.
3. Confirms the file was received.
4. Verifies the file is not empty.
5. Creates a timestamped archive copy.
6. Logs job success or failure.

### Outbound Flow

Outbound Directory → SFTP PUT → Vendor → Log

The outbound job:

1. Confirms the outbound file exists.
2. Connects to the vendor SFTP server using SSH key authentication.
3. Uploads the file to the vendor directory.
4. Checks the SFTP exit status.
5. Logs job success or failure.

## Project Structure

sftp-data-pipeline/
├── bin/
│   ├── inbound_job.sh
│   └── outbound_job.sh
├── etc/
│   └── sftp_config.sh
├── ftp/
│   ├── inbound/
│   ├── outbound/
│   └── archive/
├── log/
└── tmp/

### Directory Purpose

- `bin/` - Bash job scripts
- `etc/` - SFTP connection and job configuration
- `ftp/inbound/` - Files received from vendors
- `ftp/outbound/` - Files prepared for vendor delivery
- `ftp/archive/` - Historical copies of received files
- `log/` - Job execution logs
- `tmp/` - Temporary working files

## SFTP Authentication

The pipeline uses SSH public-key authentication instead of storing passwords in the scripts.

The private SSH key remains outside the Git repository and is referenced through the SFTP configuration.

## Running the Pipeline

Run the inbound job:

```bash
./bin/inbound_job.sh
