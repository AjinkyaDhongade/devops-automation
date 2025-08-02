#!/bin/bash

set -e

echo "==== Kubernetes Worker Node Cleanup Script ===="
echo "Node: $(hostname)"
echo "Started at: $(date)"
echo "-----------------------------------------------"

# CONFIGURABLE THRESHOLD
# THRESHOLD=80
# USAGE=$(df / | tail -1 | awk '{print $5}' | tr -d '%')

# if [ "$USAGE" -lt "$THRESHOLD" ]; then
#   echo "Disk usage is at ${USAGE}% < ${THRESHOLD}%. Skipping cleanup."
#   exit 0
# fi

# STEP 1: Prune unused containerd images (fix: add --all)
echo "[1/5] Pruning unused containerd images..."
sudo ctr -n k8s.io images prune --all || echo "No unused images to prune."

# STEP 2: Remove only non-running containers (fix: avoid deletion errors)
echo "[2/5] Removing unused (non-running) containerd containers..."
for container in $(sudo ctr -n k8s.io containers list -q); do
    if ! sudo ctr -n k8s.io task ls | grep -q "$container"; then
        echo "Deleting unused container: $container"
        sudo ctr -n k8s.io containers delete "$container"
    else
        echo "Skipping running container: $container"
    fi
done

# STEP 3: Remove unused containerd snapshots
echo "[3/5] Removing orphaned containerd snapshots..."
sudo ctr -n k8s.io snapshots list -q | xargs -r sudo ctr -n k8s.io snapshots remove

# STEP 4: Remove dangling (untagged) images with crictl
echo "[4/5] Removing dangling (untagged) images with crictl..."
for image_id in $(sudo crictl images -q | sort | uniq); do
    image_info=$(sudo crictl inspecti "$image_id" 2>/dev/null || true)
    if echo "$image_info" | grep -q '"repoTags": \[\]'; then
        echo "Removing untagged image ID: $image_id"
        sudo crictl rmi "$image_id"
    fi
done

# STEP 5: Clean logs and temporary directories
# echo "[5/5] Cleaning logs and temporary directories..."
# sudo journalctl --vacuum-time=3d
# sudo find /var/log -type f -name "*.log" -exec sudo truncate -s 0 {} \;
# sudo rm -rf /tmp/*
# sudo rm -rf /run/user/*

echo "-----------------------------------------------"
echo "Cleanup completed successfully at: $(date)"
