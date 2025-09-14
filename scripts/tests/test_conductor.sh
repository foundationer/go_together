#!/bin/bash

# Script de prueba para verificar la función crear_conductor

set -e

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_info "Compilando proyecto..."
sui move build

print_info "Publicando módulo..."
sui client publish --gas-budget 100000000 --json > publish_result.json

PACKAGE_ID=$(cat publish_result.json | jq -r '.objectChanges[] | select(.type == "published") | .packageId')
print_success "Package ID: $PACKAGE_ID"

print_info "Creando conductor..."
sui client call \
    --package "$PACKAGE_ID" \
    --module app \
    --function crear_conductor \
    --args "Juan Pérez" "Toyota Corolla 2020" \
    --gas-budget 10000000 \
    --json > conductor_creation.json

print_info "Resultado de crear_conductor:"
cat conductor_creation.json

CONDUCTOR_ID=$(cat conductor_creation.json | jq -r '.objectChanges[] | select(.type == "created") | .objectId')
if [ -z "$CONDUCTOR_ID" ] || [ "$CONDUCTOR_ID" = "null" ]; then
    print_error "No se pudo obtener el ID del conductor"
    exit 1
fi
print_success "Conductor creado exitosamente: $CONDUCTOR_ID"

print_info "Verificando que el conductor existe..."
sui client object "$CONDUCTOR_ID"

print_success "Prueba completada exitosamente"
