#!/bin/bash
# -----------------------------------------------------------------------------
# SECRET GENERATOR FOR GIT-OPS STACK
# This script generates random strong credentials for applications that require
# external secrets (Redis, MinIO, Grafana, etc.) and creates them in the cluster.
#
# USAGE: 
#   ./scripts/setup-secrets.sh [service]
# -----------------------------------------------------------------------------

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

generate_password() {
    # Strip any potential newlines/whitespace from openssl output
    openssl rand -base64 16 | tr -d '\n '
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
        return 1 # Indicate existing
    else
        echo -e "${YELLOW}Creating secret '${secret_name}'...${NC}"
        # Construct the arguments array to avoid shell splitting issues
        local args=()
        for literal in $literals; do
            args+=(--from-literal="$literal")
        done
        kubectl create secret generic "$secret_name" -n "$namespace" "${args[@]}"
        echo -e "${GREEN}✓ Created secret '${secret_name}'${NC}"
        return 0 # Indicate created
    fi
}

setup_redis() {
    echo -e "${BLUE}=== Setup Redis ===${NC}"
    # Namespace: database
    local REDIS_PASS=$(generate_password)
    if create_secret_if_missing "database" "redis-secret" "password=${REDIS_PASS}"; then
        echo -e "Redis Password: ${REDIS_PASS}"
    else
        echo -e "Redis Secret already exists. To view: kubectl get secret redis-secret -n database -o go-template='{{.data.password | base64decode}}'"
    fi
}

setup_minio() {
    echo -e "${BLUE}=== Setup MinIO ===${NC}"
    # Namespace: minio
    local MINIO_USER="admin"
    local MINIO_PASS=$(generate_password)
    if create_secret_if_missing "minio" "minio-secret" "rootUser=${MINIO_USER} rootPassword=${MINIO_PASS}"; then
         echo -e "MinIO Created: ${MINIO_USER} / ${MINIO_PASS}"
    else
         echo -e "MinIO Secret already exists. To view: kubectl get secret minio-secret -n minio -o go-template='{{.data.rootPassword | base64decode}}'"
    fi
}

setup_grafana() {
     echo -e "${BLUE}=== Setup Grafana ===${NC}"
     # Namespace: monitoring
     local GRAFANA_USER="admin"
     local GRAFANA_PASS=$(generate_password)
     if create_secret_if_missing "monitoring" "grafana-secret" "admin-user=${GRAFANA_USER} admin-password=${GRAFANA_PASS}"; then
         echo -e "Grafana Created: ${GRAFANA_USER} / ${GRAFANA_PASS}"
     else
         echo -e "Grafana Secret already exists. To view: kubectl get secret grafana-secret -n monitoring -o go-template='{{.data.admin-password | base64decode}}'"
     fi
}

setup_vaultwarden() {
    echo -e "${BLUE}=== Setup Vaultwarden ===${NC}"
    # Namespace: vaultwarden
    local VAULTWARDEN_TOKEN=$(generate_password)
    if create_secret_if_missing "vaultwarden" "vaultwarden-secret" "adminToken=${VAULTWARDEN_TOKEN}"; then
        echo -e "Vaultwarden Token: ${VAULTWARDEN_TOKEN}"
    else
        echo -e "Vaultwarden Secret already exists."
    fi
}

usage() {
    echo "Usage: $0 [service]"
    echo "Available services: redis, minio, grafana, vaultwarden"
    echo "If no service is specified, all secrets will be checked/created."
    exit 1
}

# MAIN EXECUTION
if [ -z "$1" ]; then
    echo -e "${BLUE}=== Starting Full Secret Setup ===${NC}"
    setup_redis
    setup_minio
    setup_grafana
    setup_vaultwarden
    echo -e "\n${GREEN}=== Secrets Configured Successfully ===${NC}"
else
    case "$1" in
        redis)
            setup_redis
            ;;
        minio)
            setup_minio
            ;;
        grafana)
            setup_grafana
            ;;
        vaultwarden)
            setup_vaultwarden
            ;;
        *)
            echo -e "${RED}Invalid service: $1${NC}"
            usage
            ;;
    esac
fi
