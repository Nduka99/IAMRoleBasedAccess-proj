#!/bin/bash

for file in mfa_seeds/*.txt; do
    username=$(basename "$file" -seed.txt)
    qrencode -o "mfa_seeds/$username-qr.png" "otpauth://totp/AWS:$username?secret=$(cat $file)&issuer=AWS"
done