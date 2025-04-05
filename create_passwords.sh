#!/bin/bash
#assign passwords  to all users in the user.txt file 
while IFS= read -r username; do
    echo "Assigning password to $username"
    aws iam create-login-profile --user-name "$username" --password "Password123!!56!!7" --no-password-reset-required
done < "users.txt"

