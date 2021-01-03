#!/bin/bash
# script to encrypt secrets
gpg --import bootstrap/gpg.pub

sops --encrypt 	"--pgp=      42889E63D41F6057495CDF1F05984DF1D2E5D7A1" 	--encrypted-regex '^(data|stringData)$' 	--in-place $1
