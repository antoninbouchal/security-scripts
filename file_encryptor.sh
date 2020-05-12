#!/bin/sh

helpFunction()
{
	echo ""
	echo "Usage: $0 [-k ./keys]"
	echo "\t-k Dir path with public keys ( default \"./keys\" )"
	echo "\t-f Target file to encrypt"
	exit 1 # Exit script after printing help
}

while getopts "f:k:" opt
do
	case "$opt" in
		k ) KEYS_DIR="$OPTARG" ;;
		f ) FILE_PATH="$OPTARG" ;;
		? ) helpFunction ;;
	esac
done

if [ -z $FILE_PATH ]; then
	echo "You must set target file with parameter \"-f\""
	exit 1
fi

if [ ! -f "$FILE_PATH" ]; then
	echo "Target file don't exists"
	exit 1
fi


# Set default key directory if is not set in parameters
if [ -z $KEYS_DIR ]; then
	KEYS_DIR="${PWD}/keys"
fi


# Check if key directory exists
if [ ! -d $KEYS_DIR ]; then
	echo "Keys directory was not found.\nKeys dir: ${KEYS_DIR}"
fi


# Get random public key ending for `.pem.pub`
shopt -s nullglob

PUB_KEYS=($KEYS_DIR/*.pem.pub)

if (( ! ${#PUB_KEYS[@]} )); then
    echo "No public PEM key was found."
    exit 1
fi

PUB_KEY=${PUB_KEYS[$RANDOM % ${#PUB_KEYS[@]}]}

# Check if public key is valid
openssl rsa -inform PEM -pubin -in $PUB_KEY -noout &> /dev/null
if [ $? != 0 ] ; then
    echo "Selected public key is not valid.\nSelected key: ${PUB_KEY}"
    exit 1
fi

FILE_NAME=$(basename $FILE_PATH)
ENCRYPTED_FILE_NAME=$FILE_NAME.enc

SECRET_KEY_FILE_NAME="secret.key"
ENCRYPTED_SECRET_KEY_FILE_NAME=$SECRET_KEY_FILE_NAME.enc

ARCHIVE_FILE_NAME=$FILE_NAME.tar.gz


# Generate secred key for synchronous encryption
openssl rand -out $SECRET_KEY_FILE_NAME 1024

# Encrypt target file
openssl aes-256-cbc -pbkdf2 -in $FILE_PATH -out $ENCRYPTED_FILE_NAME -pass file:$SECRET_KEY_FILE_NAME

# Encrypt secret key file
openssl rsautl -encrypt -inkey $PUB_KEY -pubin -in $SECRET_KEY_FILE_NAME -out $SECRET_KEY_FILE_NAME.enc

# Archive encrypted file with encrypted secret key
tar -czf $ARCHIVE_FILE_NAME $ENCRYPTED_FILE_NAME $ENCRYPTED_SECRET_KEY_FILE_NAME

# Clean useless files
rm $SECRET_KEY_FILE_NAME $ENCRYPTED_SECRET_KEY_FILE_NAME $ENCRYPTED_FILE_NAME

echo "File \"${FILE_NAME}\" was successfully encrypted and archived to \"$ARCHIVE_FILE_NAME\""
