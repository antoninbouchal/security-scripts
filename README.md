# Security scripts

Scripts for generating keys and secure files.

## Why?

You have one file with secret data. For example recovery keys for 2FA of some service.

And you wanna upload it to some cloud storage, because every hardware method is not practical, because you constantly loose things.

But you are afraid, that somebody can stole them on cloud too.

__Solution:__

- Genearate big amount of encrytion keys with strong passphrase
- Randomly choose one of them to encrypt file
- Upload encrypted file to cloud.
	- You can upload keys next to it. Passphrase is strong and cloud is already secured. Or maybe some other cloud storage. Your choose.
- Do something wrong, so you need to decrypt file with secred data.
- Decrypt file with script, which try to decrypt file with every one of key.
- Profit!

## Usage

### 1. Generate lots of keys

Go to dir of your desires and use __keys generator__.

```
mkdir keys
cd keys
./keys_generator.sh
```

## Scripts

### keys_generator.sh

Generate choosed number of new keys for encrypting 
