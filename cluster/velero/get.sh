#!/bin/bash
if false; then
	curl --fail -SsLO https://github.com/vmware-tanzu/velero/releases/download/v1.7.0/velero-v1.7.0-linux-arm64.tar.gz
	tar -xvzf velero*.tar.gz
	mkdir -p ~/.local/bin
	mv velero-v*/velero ~/.local/bin
fi

kubectl get secret -n velero cloud-credentials -o jsonpath='{.data.cloud}' | base64 -d - > cloud-credentials
velero install --dry-run -o yaml --provider aws --plugins velero/velero-plugin-for-aws:v1.3.0 --bucket k3s-backup  --backup-location-config region=minio,s3Url=http://192.168.1.150:9000,s3ForcePathStyle=true --snapshot-location-config region=minio,s3Url=http://192.168.1.150:9000,s3ForcePathStyle=true --use-restic --secret-file=cloud-credentials > velero.yaml
# TODO: ...
echo "Remove secret.."
