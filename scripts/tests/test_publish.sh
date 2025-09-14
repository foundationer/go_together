#!/bin/bash

# Script de prueba para verificar la extracción del package ID

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

print_info "Resultado de publicación:"
cat publish_result.json

print_info "Extrayendo package ID..."
PACKAGE_ID=$(cat publish_result.json | jq -r '.objectChanges[] | select(.type == "published") | .packageId')

if [ -z "$PACKAGE_ID" ] || [ "$PACKAGE_ID" = "null" ]; then
    print_error "No se pudo extraer el Package ID"
    print_info "Intentando método alternativo..."
    
    # Método alternativo: buscar en la respuesta completa
    PACKAGE_ID=$(cat publish_result.json | jq -r '.effects.created[] | select(.reference.objectId) | .reference.objectId' | head -1)
    
    if [ -z "$PACKAGE_ID" ] || [ "$PACKAGE_ID" = "null" ]; then
        print_error "Método alternativo también falló"
        print_info "Estructura del JSON:"
        cat publish_result.json | jq '.'
        exit 1
    fi
fi

print_success "Package ID extraído: $PACKAGE_ID"
echo "$PACKAGE_ID" > package_id.txt

print_info "Verificando que el package ID es válido..."
if [[ "$PACKAGE_ID" =~ ^0x[0-9a-fA-F]+$ ]]; then
    print_success "Package ID tiene formato válido"
else
    print_error "Package ID no tiene formato válido: $PACKAGE_ID"
    exit 1
fi

print_success "Prueba completada exitosamente"
