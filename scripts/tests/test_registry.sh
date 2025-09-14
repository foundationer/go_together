#!/bin/bash

# Script de prueba para verificar las funciones de registro

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

print_info "Creando registro de conductores..."
sui client call \
    --package "$PACKAGE_ID" \
    --module app \
    --function crear_registro \
    --gas-budget 10000000 \
    --json > conductor_registry.json

print_info "Resultado de crear_registro:"
cat conductor_registry.json

CONDUCTOR_REGISTRY_ID=$(cat conductor_registry.json | jq -r '.objectChanges[] | select(.type == "created") | .objectId')
if [ -z "$CONDUCTOR_REGISTRY_ID" ] || [ "$CONDUCTOR_REGISTRY_ID" = "null" ]; then
    print_error "No se pudo obtener el ID del registro de conductores"
    exit 1
fi
print_success "Registro de conductores creado: $CONDUCTOR_REGISTRY_ID"

print_info "Creando registro de pasajeros..."
sui client call \
    --package "$PACKAGE_ID" \
    --module app \
    --function crear_registro_pasajeros \
    --gas-budget 10000000 \
    --json > passenger_registry.json

print_info "Resultado de crear_registro_pasajeros:"
cat passenger_registry.json

PASSENGER_REGISTRY_ID=$(cat passenger_registry.json | jq -r '.objectChanges[] | select(.type == "created") | .objectId')
if [ -z "$PASSENGER_REGISTRY_ID" ] || [ "$PASSENGER_REGISTRY_ID" = "null" ]; then
    print_error "No se pudo obtener el ID del registro de pasajeros"
    exit 1
fi
print_success "Registro de pasajeros creado: $PASSENGER_REGISTRY_ID"

print_success "Prueba completada exitosamente"
