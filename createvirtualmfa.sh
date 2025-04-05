#!/bin/bash

USER_FILE="users.txt"
OUTPUT_DIR="mfa_seeds"

# Create output directory for seed files
mkdir -p "$OUTPUT_DIR"

# Check if the user file exists
if [ ! -f "$USER_FILE" ]; then
    echo "Error: $USER_FILE not found!"
    exit 1
fi

# Read each user from the file
while IFS= read -r username; do
    # Skip empty lines
    if [ -z "$username" ]; then
        continue
    fi

    echo "Processing MFA for: $username"

    # Step 1: Create a virtual MFA device
    MFA_DEVICE_NAME="mfa-$username"
    aws iam create-virtual-mfa-device --virtual-mfa-device-name "$MFA_DEVICE_NAME" --outfile "$OUTPUT_DIR/$username-seed.txt" --bootstrap-method Base32StringSeed

    if [ $? -ne 0 ]; then
        echo "Failed to create MFA device for $username"
        continue
    fi

    # Step 2: Extract the MFA ARN from the output (CLI doesn’t return it directly, so we infer it)
    MFA_ARN="arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):mfa/$MFA_DEVICE_NAME"

    # Step 3: Normally, the user scans the seed and provides two codes.
    # For automation, you’d need to manually generate codes from the seed (not directly possible via CLI).
    # Instead, output instructions for the user.
    echo "MFA device created for $username. Seed file saved as $OUTPUT_DIR/$username-seed.txt"
    echo "Instruct $username to scan the seed and provide two consecutive MFA codes to enable it."

done < "$USER_FILE"

echo "Next step: Users must scan their seed files and provide MFA codes to enable devices."