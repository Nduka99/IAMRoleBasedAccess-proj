#!/bin/bash 
#create access keys for users in users.txt
while IFS= read -r username; do
    echo "Creating access keys for user: $username"
    aws iam create-access-key --user-name "$username"
done < "users.txt"