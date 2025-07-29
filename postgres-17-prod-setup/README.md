# PostgreSQL 17.2 Community Edition Installer  
**For: RHEL 9.6**

---

## 📌 About

This script installs **PostgreSQL 17.2 Community Edition** on a **RHEL 9.6** VM.  
It’s designed for **production use**, with simple, clear steps and best practices.

---

## 🗂️ Files

- `install_postgres17_prod.sh` — Main installation script.

---

## ⚙️ What it does

1. Updates your system packages.
2. Installs `wget` (if missing).
3. Adds the official PostgreSQL Global Development Group (PGDG) YUM repository.
4. Disables the default RHEL PostgreSQL module to avoid conflicts.
5. Installs the PostgreSQL 17.2 server.
6. Initializes the PostgreSQL database cluster.
7. Enables the PostgreSQL service to start at boot.
8. Starts the PostgreSQL service.
9. Checks the PostgreSQL service status.
10. Prompts you to set a **strong password** for the `postgres` superuser.

---

## 🚀 How to run

```bash
# 1️⃣ Make the script executable
chmod +x install_postgres17_prod.sh

# 2️⃣ Run the script
./install_postgres17_prod.sh

## 🔒 After install (Important)

> **✅ By default, PostgreSQL only listens on `localhost`.**
>
> To allow secure remote connections:
>
> 1️⃣ **Edit `postgresql.conf`:**  
> ```bash
> sudo vi /var/lib/pgsql/17/data/postgresql.conf
> ```
> Set:  
> ```conf
> listen_addresses = '*'
> ```
> ➡️ Or better: use only trusted IPs.
>
> 2️⃣ **Edit `pg_hba.conf`:**  
> ```bash
> sudo vi /var/lib/pgsql/17/data/pg_hba.conf
> ```
> Add:  
> ```conf
> host    all    all    YOUR_APP_SUBNET/24    md5
> ```
>
> 3️⃣ **Reload PostgreSQL:**  
> ```bash
> sudo systemctl restart postgresql-17
> ```
>
> 4️⃣ **Open the firewall for trusted IPs only:**  
> ```bash
> sudo firewall-cmd --add-service=postgresql --permanent
> sudo firewall-cmd --reload
> ```
