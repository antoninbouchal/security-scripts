#!/bin/sh

read -p "Number of generated keys:" COUNT
read -s -p "Passphrase:" PASS
echo
read -s -p "Passphrase again:" PASS2
echo

if [[ $PASS != $PASS2 ]]; then
	echo "Passphrases not match"
	exit 0
fi

for ((i=1;i<=COUNT;i++)); do
    echo "Generating key number ${i}"
    ssh-keygen -t rsa -b 4096 -q -a 1000 -N "${PASS}" -f "./id_rsa_${i}.key"
done


