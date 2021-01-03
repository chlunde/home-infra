#!/bin/bash
set -x

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
export GNUPGHOME="$SCRIPT_DIR/.gnupg"

cd $SCRIPT_DIR

if ! gpg --list-secret-keys flux@example.com > /dev/null
then
	mkdir -m 0700 .gnupg
	cd .gnupg
	cat >keydetails <<EOF
	    %echo Generating a basic OpenPGP key
	    Key-Type: RSA
	    Key-Length: 2048
	    Subkey-Type: RSA
	    Subkey-Length: 2048
	    Name-Real: flux
	    Name-Comment: flux
	    Name-Email: flux@example.com
	    Expire-Date: 0
	    %no-ask-passphrase
	    %no-protection
	    %pubring pubring.kbx
	    %secring trustdb.gpg
	    # Do a commit here, so that we can later print "done" :-)
	    %commit
	    %echo done
EOF

	gpg --verbose --batch --gen-key keydetails

	# Set trust to 5 for the key so we can encrypt without prompt.
	echo -e "5\ny\n" | gpg --command-fd 0 --expert --edit-key flux@example.com trust;

	# Test that the key was created and the permission the trust was set.
	gpg --list-keys

	# Test the key can encrypt and decrypt.
	gpg -e -a -r flux@example.com keydetails

	# Delete the options and decrypt the original to stdout.
	rm keydetails
	gpg -d keydetails.asc
	rm keydetails.asc
	cd ..
fi

sec=$(gpg --list-secret-keys flux@example.com | grep -A1 ^sec | tail -n1)
echo $sec

gpg --export-secret-keys --armor $sec | kubectl create secret generic sops-gpg \
	--namespace=flux-system --from-file=sops.asc=/dev/stdin

gpg --export-secret-keys --armor $sec | kubectl create secret --dry-run=client -o yaml generic sops-gpg \
	--namespace=flux-system --from-file=sops.asc=/dev/stdin > gpg-sops-asc.yaml

gpg --export --armor $sec > gpg.pub

which go || sudo snap install --classic go
test -f ~/go/bin/age || (cd /; GO111MODULE=on go get filippo.io/age/cmd/age@master)
export PATH=$PATH:$HOME/go/bin

(curl https://github.com/chlunde.keys; echo ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFq6axcsOHb66/k0aiAjj0srU31wGabaosZ9KcEC3nG3 chlunde@localhost.localdomain
) | grep ssh-ed25519 | age -R - gpg-sops-asc.yaml > gpg-sops-asc.yaml.age

kubectl -n default create secret generic basic-auth \
--from-literal=user=admin \
--from-literal=password=change-me \
--dry-run=client \
-o yaml > basic-auth.yaml

sops --encrypt \
"--pgp=$sec" \
--encrypted-regex '^(data|stringData)$' \
--in-place basic-auth.yaml

cat > enc.sh <<EOF
#!/bin/bash
# script to encrypt secrets
gpg --import bootstrap/gpg.pub

sops --encrypt \
	"--pgp=$sec" \
	--encrypted-regex '^(data|stringData)$' \
	--in-place \$1
EOF
chmod +x enc.sh
mv enc.sh ..
