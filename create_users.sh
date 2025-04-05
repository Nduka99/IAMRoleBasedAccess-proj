#!/bin/bash
USER_FILE="users.txt"

while IFS= read -r username; do
    echo "Creating user: $username"
    aws iam create-user --user-name "$username"
done < "$USER_FILE"
