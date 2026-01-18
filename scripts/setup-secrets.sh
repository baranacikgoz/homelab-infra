#!/bin/bash
# -----------------------------------------------------------------------------
# SECRET GENERATOR FOR GIT-OPS STACK
# This script generates random strong credentials for applications that require
# external secrets (Redis, MinIO, Grafana, etc.) and creates them in the cluster.
#
# USAGE: ./scripts/setup-secrets.sh
# -----------------------------------------------------------------------------

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

generate_password() {
    openssl rand -base64 16
}

create_secret_if_missing() {
    local namespace=$1
    local secret_name=$2
    local literals=$3
    
    echo -e "${BLUE}Checking secret '${secret_name}' in namespace '${namespace}'...${NC}"
    
    # Ensure namespace exists
    kubectl create namespace "$namespace" --dry-run=client -o yaml | kubectl apply -f -

    if kubectl get secret "$secret_name" -n "$namespace" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Secret '${secret_name}' already exists.${NC}"
    else
        echo -e "${YELLOW}Creating secret '${secret_name}'...${NC}"
        # Construct command
        local cmd="kubectl create secret generic $secret_name -n $namespace"
        for literal in $literals; do
            cmd="$cmd --from-literal=$literal"
        done
        eval "$cmd"
        echo -e "${GREEN}✓ Created secret '${secret_name}'${NC}"
    fi
}

echo -e "${BLUE}=== Starting Secret Setup ===${NC}"

# -----------------------------------------------------------------------------
# 1. REDIS (Namespace: database)
# -----------------------------------------------------------------------------
REDIS_PASS=$(generate_password)
create_secret_if_missing "database" "redis-secret" "password=${REDIS_PASS}"

# -----------------------------------------------------------------------------
# 2. MINIO (Namespace: minio)
# -----------------------------------------------------------------------------
MINIO_user="admin"
MINIO_PASS=$(generate_password)
create_secret_if_missing "minio" "minio-secret" "rootUser=${MINIO_user} rootPassword=${MINIO_PASS}"

# -----------------------------------------------------------------------------
# 3. GRAFANA (Namespace: monitoring)
# -----------------------------------------------------------------------------
GRAFANA_USER="admin"
GRAFANA_PASS=$(generate_password)
create_secret_if_missing "monitoring" "grafana-secret" "admin-user=${GRAFANA_USER} admin-password=${GRAFANA_PASS}"

# -----------------------------------------------------------------------------
# OUTPUT SUMMARY
# -----------------------------------------------------------------------------
echo -e "\n${GREEN}=== Secrets Configured Successfully ===${NC}"
echo "Use the following credentials (SAVE THEM NOW, they won't be shown again if secrets exist):"
echo "----------------------------------------------------------------"
echo "Redis    (database/redis-secret)   : ${REDIS_PASS}"
echo "MinIO    (minio/minio-secret)      : ${MINIO_user} / ${MINIO_PASS}"
echo "Grafana  (monitoring/grafana-secret): ${GRAFANA_USER} / ${GRAFANA_PASS}"
echo "----------------------------------------------------------------"
echo -e "${YELLOW}Note: If secrets already existed, the values above are NEWly generated and NOT what is in the cluster.${NC}"
echo -e "${YELLOW}To view existing secrets: kubectl get secret <name> -n <ns> -o go-template='{{.data.<key> | base64decode}}'${NC}"
