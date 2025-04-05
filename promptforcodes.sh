#!/bin/bash
USER_FILE="users.txt"
CODES_FILE="mfa_codes.txt"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Function to validate a six-digit code
validate_code() {
    local code=$1
    if [[ ! $code =~ ^[0-9]{6}$ ]]; then
        echo "Error: '$code' is not a six-digit number."
        return 1
    fi
    return 0
}

# Read codes into an associative array
declare -A mfa_codes
while read -r username code1 code2; do
    if [ -z "$username" ]; then
        continue
    fi
    mfa_codes["$username,code1"]="$code1"
    mfa_codes["$username,code2"]="$code2"
done < "$CODES_FILE"

# Process users
while IFS= read -r username; do
    if [ -z "$username" ]; then
        continue
    fi
    MFA_ARN="arn:aws:iam::$ACCOUNT_ID:mfa/mfa-$username"
    echo "Enabling MFA for $username (ARN: $MFA_ARN)"

    code1="${mfa_codes[$username,code1]}"
    code2="${mfa_codes[$username,code2]}"

    # Validate codes
    if ! validate_code "$code1" || ! validate_code "$code2"; then
        echo "Skipping $username due to invalid codes in $CODES_FILE"
        continue
    fi

    # Run the AWS command
    aws iam enable-mfa-device --user-name "$username" --serial-number "$MFA_ARN" --authentication-code1 "$code1" --authentication-code2 "$code2"
    if [ $? -eq 0 ]; then
        echo "MFA enabled for $username"
    else
        echo "Failed to enable MFA for $username"
    fi
done < "$USER_FILE"