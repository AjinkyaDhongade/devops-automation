#!/bin/bash

# --------------------------------------------
# PostgreSQL 17.2 Community Edition Installer
# For: RHEL 9.6
# Author: Shraddha's DevOps Script 📌
# --------------------------------------------

set -e  # Exit immediately if a command exits with a non-zero status

echo "STEP 1: Update system packages"
sudo dnf update -y

echo "STEP 2: Install wget if not installed"
sudo dnf install -y wget

echo "STEP 3: Add the official PostgreSQL Global Development Group (PGDG) YUM repository"
sudo dnf install -y https://download.postgresql.org/pub/repos/yum/17/redhat/rhel-9-x86_64/pgdg-redhat-repo-latest.noarch.rpm

echo "STEP 4: Disable the built-in PostgreSQL module"
sudo dnf -qy module disable postgresql

echo "STEP 5: Install PostgreSQL 17 server package"
sudo dnf install -y postgresql17-server

echo "STEP 6: Initialize PostgreSQL database cluster"
/usr/pgsql-17/bin/postgresql-17-setup initdb

echo "STEP 7: Enable PostgreSQL to start on boot"
sudo systemctl enable postgresql-17

echo "STEP 8: Start PostgreSQL service"
sudo systemctl start postgresql-17

echo "STEP 9: Check PostgreSQL service status"
sudo systemctl status postgresql-17

echo "STEP 10: Switch to postgres user and set password"
sudo -i -u postgres psql -c "\\password postgres"

echo "Installation complete! PostgreSQL 17.2 is ready."
echo "------------------------------------------------------"
echo "🔑 Default connection: psql -U postgres"
echo "------------------------------------------------------"
