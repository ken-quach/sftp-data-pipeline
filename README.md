# SFTP Data Pipeline

A Bash-based file transfer pipeline that simulates automated data exchange between a company and an external vendor using SFTP.

The project demonstrates Linux/Bash scripting, SSH key authentication, inbound and outbound SFTP transfers, configuration management, file validation, logging, error handling, and file archiving.

## Architecture

### Inbound Flow

```text
Vendor → SFTP GET → Inbound Directory → Validation → Archive → Log
```

The inbound job:

1. Connects to the vendor SFTP server using SSH key authentication.
2. Downloads a vendor CSV file.
3. Confirms the file was received.
4. Verifies the file is not empty.
5. Creates a timestamped archive copy.
6. Logs job success or failure.

### Outbound Flow

```text
Outbound Directory → SFTP PUT → Vendor → Log
```

The outbound job:

1. Confirms the outbound file exists.
2. Connects to the vendor SFTP server using SSH key authentication.
3. Uploads the file to the vendor directory.
4. Checks the SFTP exit status.
5. Logs job success or failure.

## Project Structure

```text
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
```

### Directory Purpose

- `bin/` - Bash job scripts
- `etc/` - SFTP connection and job configuration
- `ftp/inbound/` - Files received from vendors
- `ftp/outbound/` - Files prepared for vendor delivery
- `ftp/archive/` - Historical copies of received files
- `log/` - Job execution logs
- `tmp/` - Temporary working files

## SFTP Authentication

The pipeline uses SSH public-key authentication instead of storing passwords directly in the job scripts.

The private SSH key remains outside the Git repository and is referenced through the SFTP configuration file.

The project uses three important SSH concepts:

- **Private key** - Stored securely on the client machine and never committed to Git.
- **Public key** - Added to the SFTP server to authorize the client.
- **Host key** - Used by the client to verify the identity of the SFTP server.

## Configuration

SFTP connection settings are stored separately from the job logic in:

```text
etc/sftp_config.sh
```

Example configuration:

```bash
SFTP_HOST="localhost"
SFTP_USER="your_username"
SFTP_KEY="$HOME/.ssh/sftp_pipeline_key"

REMOTE_INBOUND_DIR="vendor_sftp/inbound"
REMOTE_OUTBOUND_DIR="vendor_sftp/from_company"
```

The Bash jobs load these settings using `source`, allowing connection parameters to be managed separately from the transfer logic.

## Running the Pipeline

Run the inbound job:

```bash
./bin/inbound_job.sh
```

Run the outbound job:

```bash
./bin/outbound_job.sh
```

A successful job returns exit code `0`.

The exit code can be checked with:

```bash
echo $?
```

Failed jobs return a non-zero exit code.

## Inbound Processing

The inbound job downloads a file from the simulated vendor using SFTP:

```text
Vendor SFTP
     |
     | GET
     v
ftp/inbound/
     |
     | Validate
     v
ftp/archive/
```

The job checks that the downloaded file:

- Exists
- Is not empty

After successful validation, a timestamped copy is placed in the archive directory.

Example:

```text
20260923_100446_vendor_customer.csv
```

## Outbound Processing

The outbound job transfers a locally generated file to the simulated vendor:

```text
ftp/outbound/
     |
     | PUT
     v
Vendor SFTP
```

Before attempting the transfer, the job verifies that the outbound file exists.

The SFTP process exit status is captured and used to determine whether the job completed successfully.

## Logging

Both jobs write operational information to the `log/` directory.

Example events include:

- Successful file transfers
- Missing files
- Empty inbound files
- Failed SFTP connections
- Successful archive operations
- Job completion

Runtime log files are excluded from Git so generated operational data is not committed to the repository.

## Error Handling

The Bash scripts use exit codes to communicate job status.

```text
0     Successful execution
non-0 Failed execution
```

For example, the inbound job exits with a failure status if:

- The SFTP connection fails
- The expected file is not received
- The received file is empty
- The archive operation fails

This allows the scripts to be integrated with schedulers or monitoring systems in the future.

## Development Environment

This project uses a localhost SFTP server to simulate an external vendor environment.

Although the company and vendor endpoints are hosted on the same development machine, the project performs actual SFTP connections using SSH authentication and SFTP `GET` and `PUT` operations.

This provides a safe environment for practicing automated vendor file-transfer workflows without requiring access to a production SFTP server.

## Skills Demonstrated

- Linux command line
- Bash scripting
- SFTP
- SSH public-key authentication
- Inbound and outbound file transfers
- File transfer automation
- Configuration management
- Environment variables
- Exit-code handling
- Error handling
- Operational logging
- File validation
- File archiving
- Git and GitHub

## Future Improvements

Potential future enhancements include:

- Schedule jobs using cron
- Support configurable file names
- Support multiple vendor configurations
- Add email or mobile notifications for failed jobs
- Add additional data-quality validation
- Encrypt or decrypt files using PGP
- Load inbound data into a database
- Add retry logic for failed transfers
- Containerize the SFTP test environment
