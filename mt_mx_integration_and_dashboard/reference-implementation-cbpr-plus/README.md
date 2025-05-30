# SWIFT MT/MX File Listener & Log Forwarder

This project monitors a directory for new or changed SWIFT MT/MX message files, determines the message type, and invokes the appropriate Ballerina listener (`mt_listener.bal` or `mx_listener.bal`). It writes logs to specific files based on message direction (inward/outward). Fluent Bit tails these log files and forwards new log entries to OpenSearch for indexing and analysis.

---

## Prerequisites

- [Ballerina](https://ballerina.io/downloads/)
- [FileZilla](https://filezilla-project.org/) or any FTP client
- [Fluent Bit](https://fluentbit.io/)
- [OpenSearch](https://opensearch.org/) running on `localhost:9200`

---

## How It Works

1. FileZilla uploads SWIFT MT or MX files to the watched directory.
2. `mt_listener.bal` and `mx_listener.bal` process the message and write logs to either `inwardTranslator.log` or `outwardTranslator.log` based on message direction.
3. Fluent Bit tails these log files and forwards new entries to OpenSearch.

---

## Setup Instructions

### 1. Clone the Repository

```bash
git clone <repo-url>
cd reference-implementation-cbpr-plus
```

### 2. Configure FileZilla to Upload Files

Use FileZilla to upload SWIFT MT or MX files to the target directory monitored by the Ballerina listener.

**Steps:**

1. Open FileZilla.
2. Connect to your FTP server:
   - **Host**: `localhost` (or your FTP server IP)
   - **Username**: `<your-username>`
   - **Password**: `<your-password>`
   - **Port**: typically `21`
3. In the **Remote site** panel, navigate to the directory being watched by the Ballerina service.  
   Example: `ftp_listener/` or the path you've configured.
4. Drag and drop your SWIFT files (e.g., `.mt`, `.mx`, `.txt`, `.xml`) into the directory.

> ⚠️ **Note:** Ensure that the FTP server has write permissions to the target directory and that Ballerina is configured to watch this exact path.

```
[Your Local Machine]
        |
     (FileZilla)
        |
        V
[FTP Server Directory]
       |
  [Ballerina Listener Watches Here]
```

---

### 3. Configure Ballerina Services

Ensure `mt_listener.bal` and `mx_listener.bal` write logs in **JSON** format to:

- `ftp_listener/logs/inwardTranslator.log`
- `ftp_listener/logs/outwardTranslator.log`

---

### 4. Configure Fluent Bit

Edit `fluent-bit.conf`:

```ini
[SERVICE]
    flush        1
    daemon       Off
    log_level    info
    parsers_file parsers.conf
    plugins_file plugins.conf
    http_server  Off
    http_listen  0.0.0.0
    http_port    2020
    storage.metrics on

[INPUT]
    Name             tail
    Tag              mt_listener
    Path             C:\Users\Ajai\Documents\reference-implementation-cbpr-plus\ftp_listener\logs\inwardTranslator.log
    Parser           json
    Refresh_Interval 1
    exit_on_eof      off

[INPUT]
    Name             tail
    Tag              mx_listener
    Path             C:\Users\Ajai\Documents\reference-implementation-cbpr-plus\ftp_listener\logs\outwardTranslator.log
    Parser           json
    Refresh_Interval 1
    exit_on_eof      off

[OUTPUT]
    Name            opensearch
    Match           mt_listener
    Host            localhost
    Port            9200
    HTTP_User       admin
    HTTP_Passwd     <your_password>
    Index           inward_log
    Suppress_Type_Name On
    Logstash_Format Off
    Time_Key        @timestamp
    Generate_ID     On
    tls             On
    tls.verify      Off

[OUTPUT]
    Name            opensearch
    Match           mx_listener
    Host            localhost
    Port            9200
    HTTP_User       admin
    HTTP_Passwd     <your_password>
    Index           outward_log
    Suppress_Type_Name On
    Logstash_Format Off
    Time_Key        @timestamp
    Generate_ID     On
    tls             On
    tls.verify      Off
```

Replace `<your_password>` with your OpenSearch password.  
Adjust file paths to match your actual setup if needed.

---

### 5. Start the Services

Start the Ballerina file watcher:

```bash
bal run
```

Start Fluent Bit:

```bash
fluent-bit -c "<path-to-config>"
```

Make sure OpenSearch is running at `localhost:9200`.

---

## Usage

Upload SWIFT MT/MX files via FileZilla to the watched directory.  
The system processes and logs each message.  
Logs are automatically forwarded to OpenSearch for search and analytics.

---

## Security Notes

- Change all default passwords before deploying to production.
- Use secure TLS connections for OpenSearch (`tls.verify On`) in production environments.

---

## Troubleshooting

| Problem                    | Solution                                                                 |
|----------------------------|--------------------------------------------------------------------------|
| No logs in OpenSearch      | Check Fluent Bit logs and confirm correct file paths.                   |
| No processing of messages  | Ensure Ballerina services are running and have correct permissions.     |
| FileZilla upload fails     | Verify target FTP directory and file permissions.                       |
