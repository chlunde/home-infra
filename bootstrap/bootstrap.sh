#!/bin/sh
curl -s https://fluxcd.io/install.sh | sudo bash

flux bootstrap github \
  --components=source-controller,kustomize-controller,helm-controller,notification-controller \
  --components-extra=image-reflector-controller,image-automation-controller \
  --version=latest \
  --owner='chlunde' \
  --repository='home-infra' \
  --path='./cluster' \
  --branch='main' --personal --verbose
