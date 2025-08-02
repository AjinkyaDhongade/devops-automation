#!/bin/bash

set -e

echo "==== Kubernetes Worker Node Cleanup Script ===="
echo "Node: $(hostname)"
echo "Started at: $(date)"
echo "-----------------------------------------------"

# Threshold logic to skip if disk usage is under limit
# THRESHOLD=80
# USAGE=$(df / | tail -1 | awk '{print $5}' | tr -d '%')

# if [ "$USAGE" -lt "$THRESHOLD" ]; then
#   echo "Disk usage is at ${USAGE}% < ${THRESHOLD}%. Skipping cleanup."
#   exit 0
# fi

# Step 1 intentionally skipped — no kubectl on worker node

# Step 2: Prune unused containerd images
echo "[1/5] Pruning unused containerd images..."
sudo ctr -n k8s.io images prune || echo "No unused images to prune."

# Step 3: Remove unused containers
echo "[2/5] Removing unused containerd containers..."
sudo ctr -n k8s.io containers list -q | xargs -r sudo ctr -n k8s.io containers delete

# Step 4: Remove unused containerd snapshots
echo "[3/5] Removing unused containerd snapshots..."
sudo ctr -n k8s.io snapshots list -q | xargs -r sudo ctr -n k8s.io snapshots remove

# Step 5: Remove dangling (untagged) images with crictl
echo "[4/5] Removing dangling (untagged) images with crictl..."
for image_id in $(sudo crictl images -q | sort | uniq); do
    image_info=$(sudo crictl inspecti "$image_id" 2>/dev/null || true)
    if echo "$image_info" | grep -q '"repoTags": \[\]'; then
        echo "Removing untagged image ID: $image_id"
        sudo crictl rmi "$image_id"
    fi
done

# # Step 6: Clean logs and temporary files
# echo "[5/5] Cleaning logs and temp directories..."
# sudo journalctl --vacuum-time=3d
# sudo find /var/log -type f -name "*.log" -exec sudo truncate -s 0 {} \;
# sudo rm -rf /tmp/*
# sudo rm -rf /run/user/*

echo "-----------------------------------------------"
echo "Cleanup finished at: $(date)"
