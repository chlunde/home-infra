curl -sfL https://get.k3s.io | sh -s - server --no-deploy servicelb

sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config; sudo chown $USER.$USER ~/.kube/config


curl --fail -SsL https://github.com/stern/stern/releases/download/v1.13.1/stern_1.13.1_linux_arm64.tar.gz | tar -xzv
