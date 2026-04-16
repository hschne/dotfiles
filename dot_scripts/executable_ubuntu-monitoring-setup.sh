#!/usr/bin/env bash

set -euo pipefail

function main() {
  local email=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
    -h | --help)
      usage
      ;;
    -e | --email)
      email="$2"
      shift 2
      ;;
    -*)
      die "Unknown option: $1"
      ;;
    *)
      die "Unknown argument: $1"
      ;;
    esac
  done

  check_root

  if [[ -z "$email" ]]; then
    read -p "Enter email address for monitoring reports: " email
  fi

  if [[ -z "$email" ]]; then
    die "Email address is required for monitoring setup"
  fi

  log "Starting monitoring setup for email: $email"

  install_monitoring_packages
  configure_logwatch "$email"
  configure_rkhunter "$email"

  log "Monitoring setup completed successfully!"
  log "Weekly reports will be sent to: $email"

  return 0
}

usage() {
  cat <<EOF
Usage: ubuntu-monitoring-setup.sh [OPTIONS]

Set up monitoring tools (logwatch, rkhunter) with weekly email reports.

Options:
  -h, --help          Display this help message and exit
  -e, --email EMAIL   Email address for monitoring reports (will prompt if not provided)

Examples:
  sudo ./ubuntu-monitoring-setup.sh -e admin@example.com
  sudo ./ubuntu-monitoring-setup.sh  # Will prompt for email

  # Run from local machine
  scp ubuntu-monitoring-setup.sh root@server-ip:/tmp/
  ssh root@server-ip "chmod +x /tmp/ubuntu-monitoring-setup.sh && /tmp/ubuntu-monitoring-setup.sh -e admin@example.com"

Note: This script must be run as root or with sudo.
EOF
  exit 0
}

die() {
  local message=$1
  local code=${2:-1}
  echo "ERROR: $message" >&2
  exit "$code"
}

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

check_root() {
  if [[ $EUID -ne 0 ]]; then
    die "This script must be run as root or with sudo"
  fi
}

install_monitoring_packages() {
  log "Installing monitoring packages..."
  apt update
  apt install -y \
    logwatch \
    rkhunter \
    postfix \
    mailutils
}

configure_logwatch() {
  local email=$1

  log "Configuring logwatch..."

  # Create logwatch configuration
  mkdir -p /etc/logwatch/conf
  cat >/etc/logwatch/conf/logwatch.conf <<EOF
# Logwatch configuration for weekly reports
LogDir = /var/log
MailTo = $email
MailFrom = logwatch@$(hostname)
Print = No
Detail = Med
Service = All
Range = between -7 days and -1 days
Format = html
Archives = Yes
EOF

  # Remove logwatch from daily cron and add to weekly
  if [[ -f /etc/cron.daily/00logwatch ]]; then
    mv /etc/cron.daily/00logwatch /etc/cron.weekly/00logwatch
  fi
}

configure_rkhunter() {
  local email=$1

  log "Configuring rkhunter..."

  # Update rkhunter database
  rkhunter --update --quiet

  # Configure rkhunter
  sed -i "s/^MAIL-ON-WARNING=.*/MAIL-ON-WARNING=$email/" /etc/rkhunter.conf
  sed -i 's/^#MAIL_CMD=.*/MAIL_CMD=mail -s "[rkhunter] Warnings found for ${HOST_NAME}"/' /etc/rkhunter.conf

  # Create weekly rkhunter script
  cat >/etc/cron.weekly/rkhunter <<'EOF'
#!/bin/bash
# Weekly rkhunter scan

# Update the file properties database
/usr/bin/rkhunter --update --quiet

# Run the scan
OUTPUT=$(/usr/bin/rkhunter --cronjob --report-warnings-only --nocolors --skip-keypress 2>&1)

# Send email if warnings found
if [[ -n "$OUTPUT" ]]; then
    echo "$OUTPUT" | mail -s "[rkhunter] Security warnings found on $(hostname)" $MAIL_TO
fi
EOF

  # Make it executable
  chmod +x /etc/cron.weekly/rkhunter

  # Set email address in the script
  sed -i "s/\$MAIL_TO/$email/" /etc/cron.weekly/rkhunter
}

setup_weekly_reports() {
  local email=$1

  log "Setting up weekly system reports..."

  # Create comprehensive weekly report script
  cat >/etc/cron.weekly/system-report <<EOF
#!/bin/bash
# Weekly system health report

HOSTNAME=\$(hostname)
DATE=\$(date '+%Y-%m-%d')
EMAIL="$email"

# Create temporary report file
REPORT="/tmp/system-report-\$DATE.txt"

{
    echo "=== Weekly System Report for \$HOSTNAME ===="
    echo "Report Date: \$DATE"
    echo ""
    
    echo "=== System Uptime ==="
    uptime
    echo ""
    
    echo "=== Disk Usage ==="
    df -h
    echo ""
    
    echo "=== Memory Usage ==="
    free -h
    echo ""
    
    echo "=== Last 20 Failed Login Attempts ==="
    grep "Failed password" /var/log/auth.log | tail -20 || echo "No failed login attempts found"
    echo ""
    
    echo "=== UFW Firewall Status ==="
    ufw status verbose
    echo ""
    
    echo "=== System Load Average ==="
    cat /proc/loadavg
    echo ""
    
} > "\$REPORT"

# Send the report
mail -s "[\$HOSTNAME] Weekly System Report - \$DATE" "\$EMAIL" < "\$REPORT"

# Clean up
rm -f "\$REPORT"
EOF

  chmod +x /etc/cron.weekly/system-report

  log "Initializing AIDE database (this may take a while)..."
  aideinit
  cp /var/lib/aide/aide.db.new /var/lib/aide/aide.db

  # Create weekly AIDE check
  cat >/etc/cron.weekly/aide-check <<EOF
#!/bin/bash
# Weekly AIDE file integrity check

HOSTNAME=\$(hostname)
EMAIL="$email"

# Run AIDE check
OUTPUT=\$(aide --check 2>&1)
EXIT_CODE=\$?

if [[ \$EXIT_CODE -ne 0 ]]; then
    echo "\$OUTPUT" | mail -s "[\$HOSTNAME] AIDE File Integrity Check - Changes Detected" "\$EMAIL"
fi
EOF

  chmod +x /etc/cron.weekly/aide-check
}

main "$@"

