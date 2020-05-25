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

### 2. Add keys path to .bash_profile

Because we don't wanna think always about place with keys, you can add ENV variable to .bash_profile with keys path.

```
export SECURITY_SCRIPTS_KEYS_PATH=/my/secret/path/to/keys
```

> Note: Don't use paths with spaces and relative path with (~). Script works in different process and can have problems
with it.


### 3. Create shortcuts for scripts

Run commands:

```
ln ./path/to/repo/file_encryptor.sh /usr/local/bin/encrypt
ln ./path/to/repo/file_decryptor.sh /usr/local/bin/decrypt
```

### 4. Encrypt target file

With this

```
encrypt -f /path/to/target/file
```

you generate synchronous key for file encryption. Encrypt the file with it. After that
encrypt this key with randomly chosen public key in `keys` directory and archive encryped
file with encrypted key to TAR GZIP archive.

### 5. Decrypt target archive

With command

```
decrypt -f /path/to/target/archive.tar.gz
```

decrypt archive to original file.