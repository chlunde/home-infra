#!/bin/bash
curl --fail -SsLO https://github.com/vmware-tanzu/velero/releases/download/v1.7.0/velero-v1.7.0-linux-arm64.tar.gz
tar -xvzf velero*.tar.gz
mkdir -p ~/.local/bin
mv velero-v*/velero ~/.local/bin

# TODO: ...
velero install --dry-run -o yaml --provider aws --plugins velero/velero-plugin-for-aws:v1.3.0 --bucket backups  --backup-location-config region=us-east-2 --snapshot-location-config region=us-east-2 --use-restic --no-secret > velero.yaml
