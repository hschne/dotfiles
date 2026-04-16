#!/usr/bin/env bash

set -euo pipefail

function main() {
  local username=""
  local ssh_key=""
  local skip_user=false
  local email=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
    -h | --help)
      usage
      ;;
    -u | --username)
      username="$2"
      shift 2
      ;;
    -k | --ssh-key)
      ssh_key="$2"
      shift 2
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

  log "Starting Ubuntu server setup..."

  update_system
  install_packages

  if [[ -z "$username" ]]; then
    read -p "Enter username for new user: " username
  fi

  if [[ -z "$ssh_key" ]]; then
    read -p "Enter SSH public key (or leave empty to skip): " ssh_key
  fi

  create_user "$username" "$ssh_key"

  configure_ssh
  setup_firewall
  setup_monitoring "$email"

  log "Ubuntu server setup completed successfully!"

  return 0
}

usage() {
  cat <<EOF
Usage: ubuntu-server-setup.sh [OPTIONS]

Set up an Ubuntu server with basic security configurations.

Options:
  -h, --help              Display this help message and exit
  -u, --username USER     Username for new user (will prompt if not provided)
  -k, --ssh-key KEY       SSH public key for the user (will prompt if not provided)
  --skip-user             Skip user creation (use existing users only)

Examples:
  # Run directly on server
  sudo ./ubuntu-server-setup.sh
  sudo ./ubuntu-server-setup.sh -u myuser -k "ssh-rsa AAAA..."
  sudo ./ubuntu-server-setup.sh --skip-user

  # Run from local machine (copy script to server and execute)
  scp ubuntu-server-setup.sh root@server-ip:/tmp/
  ssh root@server-ip "chmod +x /tmp/ubuntu-server-setup.sh && /tmp/ubuntu-server-setup.sh -u deploy -k '\$(cat ~/.ssh/id_rsa.pub)'"
  
  # Or using your local SSH key
  ssh root@server-ip "curl -fsSL https://your-host/ubuntu-server-setup.sh | bash -s -- -u deploy -k '\$(cat ~/.ssh/id_rsa.pub)'"

Note: This script must be run as root or with sudo on the target server.
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

update_system() {
  log "Updating system packages..."
  apt update
  apt upgrade -y
}

install_packages() {
  log "Installing essential packages..."
  apt install -y \
    vim \
    htop \
    fail2ban
}

create_user() {
  local username=$1
  local ssh_key=$2

  if [[ -z "$username" ]]; then
    die "Username cannot be empty"
  fi

  if id "$username" &>/dev/null; then
    log "User $username already exists, skipping user creation"
    return 0
  fi

  log "Creating docker group..."
  groupadd -f docker

  log "Creating user: $username"
  adduser --disabled-password --gecos "" "$username"
  usermod -aG sudo,docker "$username"

  log "Configuring passwordless sudo for $username"
  echo "$username ALL=(ALL:ALL) NOPASSWD: ALL" >"/etc/sudoers.d/$username"
  chmod 440 "/etc/sudoers.d/$username"

  if [[ -n "$ssh_key" ]]; then
    log "Setting up SSH key for $username"
    mkdir -p "/home/$username/.ssh"
    echo "$ssh_key" >"/home/$username/.ssh/authorized_keys"
    chmod 700 "/home/$username/.ssh"
    chmod 600 "/home/$username/.ssh/authorized_keys"
    chown -R "$username:$username" "/home/$username/.ssh"
  else
    log "No SSH key provided, user will need to set password manually"
  fi
}

configure_ssh() {
  log "Configuring SSH security..."

  # Configure SSH security settings
  sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
  sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
  sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config
  sed -i 's/#Port 22/Port 22/' /etc/ssh/sshd_config

  # Add additional security settings
  echo "" >>/etc/ssh/sshd_config
  echo "# Additional security settings" >>/etc/ssh/sshd_config
  echo "Protocol 2" >>/etc/ssh/sshd_config
  echo "IgnoreRhosts yes" >>/etc/ssh/sshd_config
  echo "HostbasedAuthentication no" >>/etc/ssh/sshd_config
  echo "PermitEmptyPasswords no" >>/etc/ssh/sshd_config
  echo "ChallengeResponseAuthentication no" >>/etc/ssh/sshd_config
  echo "MaxAuthTries 3" >>/etc/ssh/sshd_config
  echo "ClientAliveInterval 300" >>/etc/ssh/sshd_config
  echo "ClientAliveCountMax 2" >>/etc/ssh/sshd_config

  # Test SSH configuration
  sshd -t || die "SSH configuration test failed"

  log "Restarting SSH service..."
  systemctl restart ssh
}

setup_firewall() {
  log "Configuring UFW firewall..."

  # Reset UFW to defaults
  ufw --force reset

  # Set default policies
  ufw default deny incoming
  ufw default allow outgoing

  ufw allow ssh
  ufw allow http
  ufw allow https

  ufw --force enable

  log "Configuring fail2ban..."
  systemctl enable fail2ban
  systemctl start fail2ban
}

main "$@"
