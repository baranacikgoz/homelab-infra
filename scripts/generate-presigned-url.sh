#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Generate MinIO Presigned URL
# @raycast.mode compact
# @raycast.packageName Homelab

# Optional parameters:
# @raycast.icon 🔗
# @raycast.argument1 { "type": "text", "placeholder": "Object Name" }
# @raycast.argument2 { "type": "text", "placeholder": "Content Type (e.g. video/mp4)" }
# @raycast.argument3 { "type": "text", "placeholder": "Bucket Name", "optional": true }

# Documentation:
# @raycast.description Generates a presigned URL for MinIO and copies it to clipboard

set -e

# Configuration
ENDPOINT="minio.baranacikgoz.com"
REGION="us-east-1"
SERVICE="s3"
EXPIRATION=3600 # 1 hour

# Get the directory of the script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load .env from the same directory as the script
if [ -f "$SCRIPT_DIR/.env" ]; then
    source "$SCRIPT_DIR/.env"
else
    echo "❌ Error: .env file not found"
    exit 1
fi

# Credentials
ACCESS_KEY=${MINIO_ROOT_USER}
SECRET_KEY=${MINIO_ROOT_PASSWORD}

if [ -z "$ACCESS_KEY" ] || [ -z "$SECRET_KEY" ]; then
    echo "❌ Error: MINIO_ROOT_USER and MINIO_ROOT_PASSWORD must be defined in .env"
    exit 1
fi

# Arguments
OBJECT_NAME="$1"
CONTENT_TYPE="$2"
BUCKET_NAME="${3:-dev-memory-stream}"

if [ -z "$OBJECT_NAME" ] || [ -z "$CONTENT_TYPE" ]; then
    echo "❌ Error: Missing arguments"
    exit 1
fi

# Time setup (ISO8601)
DATE_TIME=$(date -u +'%Y%m%dT%H%M%SZ')
DATE_ONLY=$(date -u +'%Y%m%d')

# HMAC-SHA256 helper for hex (input key is string, output is hex)
hmac_sha256_hex() {
    local key="$1"
    local data="$2"
    echo -n "$data" | openssl dgst -sha256 -mac HMAC -macopt "key:$key" | sed 's/^.* //'
}

# HMAC-SHA256 helper for hex (input key is hex, output is hex)
hmac_sha256_hex_with_hexkey() {
    local hexkey="$1"
    local data="$2"
    echo -n "$data" | openssl dgst -sha256 -mac HMAC -macopt "hexkey:$hexkey" | sed 's/^.* //'
}

# 1. Canonical Request
CANONICAL_URI="/${BUCKET_NAME}/${OBJECT_NAME}"
CANONICAL_QUERY_STRING="X-Amz-Algorithm=AWS4-HMAC-SHA256"
CANONICAL_QUERY_STRING+="&X-Amz-Credential=${ACCESS_KEY}%2F${DATE_ONLY}%2F${REGION}%2F${SERVICE}%2Faws4_request"
CANONICAL_QUERY_STRING+="&X-Amz-Date=${DATE_TIME}"
CANONICAL_QUERY_STRING+="&X-Amz-Expires=${EXPIRATION}"
CANONICAL_QUERY_STRING+="&X-Amz-SignedHeaders=host"

CANONICAL_HEADERS="host:${ENDPOINT}\n"
SIGNED_HEADERS="host"
PAYLOAD_HASH="UNSIGNED-PAYLOAD"

CANONICAL_REQUEST="PUT\n${CANONICAL_URI}\n${CANONICAL_QUERY_STRING}\n${CANONICAL_HEADERS}\n${SIGNED_HEADERS}\n${PAYLOAD_HASH}"

# 2. String to Sign
CREDENTIAL_SCOPE="${DATE_ONLY}/${REGION}/${SERVICE}/aws4_request"
CANONICAL_REQUEST_HASH=$(echo -ne "$CANONICAL_REQUEST" | openssl dgst -sha256 | sed 's/^.* //')
STRING_TO_SIGN="AWS4-HMAC-SHA256\n${DATE_TIME}\n${CREDENTIAL_SCOPE}\n${CANONICAL_REQUEST_HASH}"

# 3. Calculate Signature Key
kSecret="AWS4${SECRET_KEY}"

# Step-by-step hex-based HMAC calculation
kDate=$(hmac_sha256_hex "$kSecret" "$DATE_ONLY")
kRegion=$(hmac_sha256_hex_with_hexkey "$kDate" "$REGION")
kService=$(hmac_sha256_hex_with_hexkey "$kRegion" "$SERVICE")
kSigning=$(hmac_sha256_hex_with_hexkey "$kService" "aws4_request")

# 4. Calculate Signature
SIGNATURE=$(echo -ne "$STRING_TO_SIGN" | openssl dgst -sha256 -mac HMAC -macopt "hexkey:$kSigning" | sed 's/^.* //')

# 5. Output
URL="https://${ENDPOINT}${CANONICAL_URI}?${CANONICAL_QUERY_STRING}&X-Amz-Signature=${SIGNATURE}"

echo -n "$URL" | pbcopy
echo "✅ URL copied to clipboard"
