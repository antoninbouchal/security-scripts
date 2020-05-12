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
    openssl genrsa -aes256 -passout pass:$PASS -out "./id_rsa_${i}.pem" 16384
    openssl rsa -in "./id_rsa_${i}.pem" -passin pass:$PASS -pubout -out "./id_rsa_${i}.pem.pub"
done


