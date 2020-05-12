# Security scripts

Scripts for generating keys and secure files.

## Why?

You have one file with secret data. For example recovery keys for 2FA of some service.

And you wanna upload it to some cloud storage, because every hardware method is not practical, because you constantly loose things.

But you are afraid, that somebody can stole them on cloud too.

__Solution:__

- Generate big amount of encryption keys with strong passphrase
- Randomly choose one of them to encrypt file
- Upload encrypted file to cloud.
	- You can upload keys next to it. Passphrase is strong and cloud is already secured. Or maybe some other cloud storage. Your choose.
- Do something wrong, so you need to decrypt the file with secret data.
- Decrypt the file with script, which try to decrypt the file with every one of key.
- Profit!

## Usage

### 1. Generate lots of keys

Go to dir of your desires and use __keys generator__.

```
mkdir keys
cd keys
./keys_generator.sh
```

### 2. Encrypt target file

With this

```
./file_encryptor.sh -k ./keys -f /path/to/target/file
```

you generate synchronous key for file encryption. Encrypt the file with it. After that
encrypt this key with randomly chosen public key in `keys` directory and archive encryped
file with encrypted key to TAR GZIP archive.

### 3. Decrypt target archive

With command

```
./file_decryptor.sh -k ./keys -f /path/to/target/archive.tar.gz
```

Decrypt archive to original file.