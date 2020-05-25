#!/bin/sh

helpFunction() {
  echo ""
  echo "Usage: $0 [-k ./keys]"
  echo "\t-k Dir path with public keys ( default \"./keys\" )"
  echo "\t-f Target file to encrypt"
  exit 1 # Exit script after printing help
}

while getopts "f:k:" opt; do
  case "$opt" in
  k) KEYS_DIR="$OPTARG" ;;
  f) ARHIVE_PATH="$OPTARG" ;;
  ?) helpFunction ;;
  esac
done

if [ -z $ARHIVE_PATH ]; then
  echo "You must set target archive file with parameter \"-f\""
  exit 1
fi

if [ ! -f "$ARHIVE_PATH" ]; then
  echo "Target archive file don't exists"
  exit 1
fi

# Set default key directory if is not set in parameters
if [ -z $KEYS_DIR ]; then
  if [ -z "${SECURITY_SCRIPTS_KEYS_PATH}" ]; then
    KEYS_DIR="${PWD}/keys"
  else
    KEYS_DIR=$SECURITY_SCRIPTS_KEYS_PATH
  fi
fi

ARCHIVE_FILE_NAME=$(basename $ARHIVE_PATH)

FILE_NAME=${ARCHIVE_FILE_NAME//.tar.gz/}
ENCRYPTED_FILE_NAME=$FILE_NAME.enc

SECRET_KEY_FILE_NAME="secret.key"
ENCRYPTED_SECRET_KEY_FILE_NAME=$SECRET_KEY_FILE_NAME.enc

# Unpack TAR GZIP file
mkdir -p temp
tar -C temp -zxf $ARHIVE_PATH

if [[ ! -f temp/$ENCRYPTED_FILE_NAME || ! -f temp/$ENCRYPTED_SECRET_KEY_FILE_NAME ]]; then
  echo "Archive don't include right files."
  rm -r temp
  exit 1
fi

# Try every public key in key directory until we find right one
read -s -p "Key passphrase:" PASS
echo

FAILED=1
KEYS=($(ls $KEYS_DIR/*.pem))

for KEY_PATH in $KEYS_DIR/*.pem; do
  openssl rsautl -decrypt -inkey $KEY_PATH -in temp/$ENCRYPTED_SECRET_KEY_FILE_NAME -out temp/$SECRET_KEY_FILE_NAME -passin pass:$PASS &>/dev/null
  if [ $? == 0 ]; then
    # Secret key was successfully decrypted and now we need to decrypt target file
    openssl aes-256-cbc -pbkdf2 -d -in temp/$ENCRYPTED_FILE_NAME -out $FILE_NAME -pass file:temp/$SECRET_KEY_FILE_NAME
    if [ $? == 0 ]; then
      FAILED=0
      break
    fi
  fi
done

if [ $FAILED == 0 ]; then
  echo "File \"${FILE_NAME}\" was successfully decrypted."
else
  echo "Decryption failed."
fi

rm -fr temp

exit $FAILED
