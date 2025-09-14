#!/bin/bash

# Script de prueba para verificar la función crear_viaje

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

CONDUCTOR_REGISTRY_ID=$(cat conductor_registry.json | jq -r '.objectChanges[] | select(.type == "created") | .objectId')
print_success "Registro de conductores: $CONDUCTOR_REGISTRY_ID"

print_info "Creando conductor..."
sui client call \
    --package "$PACKAGE_ID" \
    --module app \
    --function crear_conductor \
    --args "Juan Pérez" "Toyota Corolla 2020" \
    --gas-budget 10000000 \
    --json > conductor_creation.json

CONDUCTOR_ID=$(cat conductor_creation.json | jq -r '.objectChanges[] | select(.type == "created") | .objectId')
print_success "Conductor creado: $CONDUCTOR_ID"

print_info "Registrando conductor..."
sui client call \
    --package "$PACKAGE_ID" \
    --module app \
    --function registrar_conductor \
    --args "$CONDUCTOR_REGISTRY_ID" "$CONDUCTOR_ID" \
    --gas-budget 10000000

print_info "Creando registro de pasajeros..."
sui client call \
    --package "$PACKAGE_ID" \
    --module app \
    --function crear_registro_pasajeros \
    --gas-budget 10000000 \
    --json > passenger_registry.json

PASSENGER_REGISTRY_ID=$(cat passenger_registry.json | jq -r '.objectChanges[] | select(.type == "created") | .objectId')
print_success "Registro de pasajeros: $PASSENGER_REGISTRY_ID"

print_info "Creando pasajero..."
sui client call \
    --package "$PACKAGE_ID" \
    --module app \
    --function registrar_pasajero \
    --args "$PASSENGER_REGISTRY_ID" "María García" \
    --gas-budget 10000000 \
    --json > passenger_creation.json

PASSENGER_ID=$(cat passenger_creation.json | jq -r '.objectChanges[] | select(.type == "created") | .objectId')
print_success "Pasajero creado: $PASSENGER_ID"

print_info "Creando viaje..."
sui client call \
    --package "$PACKAGE_ID" \
    --module app \
    --function crear_viaje \
    --args "$CONDUCTOR_ID" "$PASSENGER_ID" "Centro de la ciudad" "Aeropuerto" \
    --gas-budget 10000000 \
    --json > trip_creation.json

print_info "Resultado de crear_viaje:"
cat trip_creation.json

TRIP_ID=$(cat trip_creation.json | jq -r '.objectChanges[] | select(.type == "created") | .objectId')
if [ -z "$TRIP_ID" ] || [ "$TRIP_ID" = "null" ]; then
    print_error "No se pudo obtener el ID del viaje"
    exit 1
fi
print_success "Viaje creado exitosamente: $TRIP_ID"

print_info "Verificando que el viaje existe..."
sui client object "$TRIP_ID"

print_success "Prueba completada exitosamente"
