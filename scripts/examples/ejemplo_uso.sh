#!/bin/bash

# Script de ejemplo para interactuar con el módulo Go Together usando Sui CLI
# Este script demuestra cómo crear registros, conductores, pasajeros y viajes

set -e  # Salir si cualquier comando falla

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para imprimir mensajes con colores
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Verificar que Sui CLI esté instalado
check_sui_cli() {
    if ! command -v sui &> /dev/null; then
        print_error "Sui CLI no está instalado. Por favor instálalo desde https://docs.sui.io/build/install"
        exit 1
    fi
    print_success "Sui CLI encontrado"
}

# Verificar que estamos en el directorio correcto
check_directory() {
    if [ ! -f "Move.toml" ]; then
        print_error "No se encontró Move.toml. Asegúrate de estar en el directorio del proyecto go_together"
        exit 1
    fi
    print_success "Directorio del proyecto verificado"
}

# Compilar el proyecto
build_project() {
    print_info "Compilando el proyecto..."
    if sui move build; then
        print_success "Proyecto compilado exitosamente"
    else
        print_error "Error al compilar el proyecto"
        exit 1
    fi
}

# Publicar el módulo
publish_module() {
    print_info "Publicando el módulo en la red..."
    
    # Obtener la dirección del publicador
    PUBLISHER_ADDRESS=$(sui client active-address)
    print_info "Dirección del publicador: $PUBLISHER_ADDRESS"
    
    # Publicar el módulo y guardar resultado en archivo temporal
    sui client publish --gas-budget 100000000 --json > publish_result.json
    
    # Extraer el package ID del resultado JSON
    PACKAGE_ID=$(cat publish_result.json | jq -r '.objectChanges[] | select(.type == "published") | .packageId')
    
    if [ -z "$PACKAGE_ID" ] || [ "$PACKAGE_ID" = "null" ]; then
        print_error "No se pudo extraer el Package ID del resultado de publicación"
        print_info "Resultado de publicación:"
        cat publish_result.json
        exit 1
    fi
    
    print_success "Módulo publicado con Package ID: $PACKAGE_ID"
    
    # Guardar el package ID para uso posterior
    echo "$PACKAGE_ID" > package_id.txt
}

# Crear registros globales
create_registries() {
    print_info "Creando registros globales..."
    
    # Verificar que el archivo package_id.txt existe y no está vacío
    if [ ! -f "package_id.txt" ] || [ ! -s "package_id.txt" ]; then
        print_error "Archivo package_id.txt no encontrado o vacío. Ejecuta 'publish' primero."
        exit 1
    fi
    
    PACKAGE_ID=$(cat package_id.txt)
    
    # Verificar que el package ID es válido
    if [ -z "$PACKAGE_ID" ] || [[ ! "$PACKAGE_ID" =~ ^0x[0-9a-fA-F]+$ ]]; then
        print_error "Package ID inválido: $PACKAGE_ID"
        exit 1
    fi
    
    # Crear registro de conductores
    print_info "Creando registro de conductores..."
    sui client call \
        --package "$PACKAGE_ID" \
        --module app \
        --function crear_registro \
        --gas-budget 10000000 \
        --json > conductor_registry.json
    
    CONDUCTOR_REGISTRY_ID=$(cat conductor_registry.json | jq -r '.objectChanges[] | select(.type == "created") | .objectId')
    if [ -z "$CONDUCTOR_REGISTRY_ID" ] || [ "$CONDUCTOR_REGISTRY_ID" = "null" ]; then
        print_error "No se pudo obtener el ID del registro de conductores"
        print_info "Resultado de la transacción:"
        cat conductor_registry.json
        exit 1
    fi
    print_success "Registro de conductores creado: $CONDUCTOR_REGISTRY_ID"
    echo "$CONDUCTOR_REGISTRY_ID" > conductor_registry_id.txt
    
    # Crear registro de pasajeros
    print_info "Creando registro de pasajeros..."
    sui client call \
        --package "$PACKAGE_ID" \
        --module app \
        --function crear_registro_pasajeros \
        --gas-budget 10000000 \
        --json > passenger_registry.json
    
    PASSENGER_REGISTRY_ID=$(cat passenger_registry.json | jq -r '.objectChanges[] | select(.type == "created") | .objectId')
    if [ -z "$PASSENGER_REGISTRY_ID" ] || [ "$PASSENGER_REGISTRY_ID" = "null" ]; then
        print_error "No se pudo obtener el ID del registro de pasajeros"
        print_info "Resultado de la transacción:"
        cat passenger_registry.json
        exit 1
    fi
    print_success "Registro de pasajeros creado: $PASSENGER_REGISTRY_ID"
    echo "$PASSENGER_REGISTRY_ID" > passenger_registry_id.txt
}

# Crear un conductor
create_driver() {
    local driver_name="$1"
    local car_model="$2"
    
    print_info "Creando conductor: $driver_name con coche: $car_model"
    
    # Verificar archivos necesarios
    if [ ! -f "package_id.txt" ] || [ ! -s "package_id.txt" ]; then
        print_error "Archivo package_id.txt no encontrado. Ejecuta 'publish' primero."
        exit 1
    fi
    
    if [ ! -f "conductor_registry_id.txt" ] || [ ! -s "conductor_registry_id.txt" ]; then
        print_error "Archivo conductor_registry_id.txt no encontrado. Ejecuta 'create_registries' primero."
        exit 1
    fi
    
    PACKAGE_ID=$(cat package_id.txt)
    CONDUCTOR_REGISTRY_ID=$(cat conductor_registry_id.txt)
    
    # Crear el conductor (se transfiere automáticamente al usuario)
    sui client call \
        --package "$PACKAGE_ID" \
        --module app \
        --function crear_conductor \
        --args "$driver_name" "$car_model" \
        --gas-budget 10000000 \
        --json > conductor_creation.json
    
    CONDUCTOR_ID=$(cat conductor_creation.json | jq -r '.objectChanges[] | select(.type == "created") | .objectId')
    if [ -z "$CONDUCTOR_ID" ] || [ "$CONDUCTOR_ID" = "null" ]; then
        print_error "No se pudo obtener el ID del conductor"
        print_info "Resultado de la transacción:"
        cat conductor_creation.json
        exit 1
    fi
    print_success "Conductor creado: $CONDUCTOR_ID"
    
    # Registrar el conductor en el registro global
    print_info "Registrando conductor en el registro global..."
    sui client call \
        --package "$PACKAGE_ID" \
        --module app \
        --function registrar_conductor \
        --args "$CONDUCTOR_REGISTRY_ID" "$CONDUCTOR_ID" \
        --gas-budget 10000000
    
    print_success "Conductor registrado exitosamente"
    echo "$CONDUCTOR_ID" > driver_id.txt
}

# Crear un pasajero
create_passenger() {
    local passenger_name="$1"
    
    print_info "Creando pasajero: $passenger_name"
    
    # Verificar archivos necesarios
    if [ ! -f "package_id.txt" ] || [ ! -s "package_id.txt" ]; then
        print_error "Archivo package_id.txt no encontrado. Ejecuta 'publish' primero."
        exit 1
    fi
    
    if [ ! -f "passenger_registry_id.txt" ] || [ ! -s "passenger_registry_id.txt" ]; then
        print_error "Archivo passenger_registry_id.txt no encontrado. Ejecuta 'create_registries' primero."
        exit 1
    fi
    
    PACKAGE_ID=$(cat package_id.txt)
    PASSENGER_REGISTRY_ID=$(cat passenger_registry_id.txt)
    
    # Registrar el pasajero
    sui client call \
        --package "$PACKAGE_ID" \
        --module app \
        --function registrar_pasajero \
        --args "$PASSENGER_REGISTRY_ID" "$passenger_name" \
        --gas-budget 10000000 \
        --json > passenger_creation.json
    
    PASSENGER_ID=$(cat passenger_creation.json | jq -r '.objectChanges[] | select(.type == "created") | .objectId')
    print_success "Pasajero creado y registrado: $PASSENGER_ID"
    echo "$PASSENGER_ID" > passenger_id.txt
}

# Crear un viaje
create_trip() {
    local origin="$1"
    local destination="$2"
    
    print_info "Creando viaje de $origin a $destination"
    
    # Verificar archivos necesarios
    if [ ! -f "package_id.txt" ] || [ ! -s "package_id.txt" ]; then
        print_error "Archivo package_id.txt no encontrado. Ejecuta 'publish' primero."
        exit 1
    fi
    
    if [ ! -f "driver_id.txt" ] || [ ! -s "driver_id.txt" ]; then
        print_error "Archivo driver_id.txt no encontrado. Ejecuta 'create_driver' primero."
        exit 1
    fi
    
    if [ ! -f "passenger_id.txt" ] || [ ! -s "passenger_id.txt" ]; then
        print_error "Archivo passenger_id.txt no encontrado. Ejecuta 'create_passenger' primero."
        exit 1
    fi
    
    PACKAGE_ID=$(cat package_id.txt)
    DRIVER_ID=$(cat driver_id.txt)
    PASSENGER_ID=$(cat passenger_id.txt)
    
    # Crear el viaje (se transfiere automáticamente al conductor)
    sui client call \
        --package "$PACKAGE_ID" \
        --module app \
        --function crear_viaje \
        --args "$DRIVER_ID" "$PASSENGER_ID" "$origin" "$destination" \
        --gas-budget 10000000 \
        --json > trip_creation.json
    
    TRIP_ID=$(cat trip_creation.json | jq -r '.objectChanges[] | select(.type == "created") | .objectId')
    if [ -z "$TRIP_ID" ] || [ "$TRIP_ID" = "null" ]; then
        print_error "No se pudo obtener el ID del viaje"
        print_info "Resultado de la transacción:"
        cat trip_creation.json
        exit 1
    fi
    print_success "Viaje creado: $TRIP_ID"
    echo "$TRIP_ID" > trip_id.txt
}

# Verificar el estado de un conductor
check_driver_status() {
    local driver_id="$1"
    
    print_info "Verificando estado del conductor: $driver_id"
    
    # Obtener información del objeto conductor
    sui client object "$driver_id" --json > driver_info.json
    
    # Extraer información relevante
    driver_name=$(cat driver_info.json | jq -r '.data.content.fields.nombre')
    car_model=$(cat driver_info.json | jq -r '.data.content.fields.coche')
    available=$(cat driver_info.json | jq -r '.data.content.fields.disponible')
    
    print_info "Conductor: $driver_name"
    print_info "Coche: $car_model"
    print_info "Disponible: $available"
}

# Verificar el estado de un viaje
check_trip_status() {
    local trip_id="$1"
    
    print_info "Verificando estado del viaje: $trip_id"
    
    # Obtener información del objeto viaje
    sui client object "$trip_id" --json > trip_info.json
    
    # Extraer información relevante
    driver_name=$(cat trip_info.json | jq -r '.data.content.fields.conductor_nombre')
    passenger_name=$(cat trip_info.json | jq -r '.data.content.fields.pasajero_nombre')
    origin=$(cat trip_info.json | jq -r '.data.content.fields.origen')
    destination=$(cat trip_info.json | jq -r '.data.content.fields.destino')
    active=$(cat trip_info.json | jq -r '.data.content.fields.activo')
    
    print_info "Conductor: $driver_name"
    print_info "Pasajero: $passenger_name"
    print_info "Origen: $origin"
    print_info "Destino: $destination"
    print_info "Activo: $active"
}

# Finalizar un viaje
finalize_trip() {
    local trip_id="$1"
    local driver_id="$2"
    
    print_info "Finalizando viaje: $trip_id"
    
    # Verificar archivos necesarios
    if [ ! -f "package_id.txt" ] || [ ! -s "package_id.txt" ]; then
        print_error "Archivo package_id.txt no encontrado. Ejecuta 'publish' primero."
        exit 1
    fi
    
    PACKAGE_ID=$(cat package_id.txt)
    
    sui client call \
        --package "$PACKAGE_ID" \
        --module app \
        --function finalizar_viaje \
        --args "$trip_id" "$driver_id" \
        --gas-budget 10000000
    
    print_success "Viaje finalizado exitosamente"
}

# Limpiar archivos temporales
cleanup() {
    print_info "Limpiando archivos temporales..."
    rm -f *.json *.txt
    print_success "Limpieza completada"
}

# Limpiar archivos temporales al inicio
cleanup_start() {
    print_info "Limpiando archivos temporales previos..."
    rm -f *.json *.txt
    print_success "Limpieza completada"
}

# Función principal
main() {
    print_info "=== Script de ejemplo para Go Together ==="
    print_info "Este script demuestra el uso del módulo de carpooling"
    
    # Verificaciones iniciales
    check_sui_cli
    check_directory
    
    # Limpiar archivos temporales previos
    cleanup_start
    
    # Compilar y publicar
    build_project
    publish_module
    
    # Crear registros
    create_registries
    
    # Crear conductor
    create_driver "Juan Pérez" "Toyota Corolla 2020"
    
    # Crear pasajero
    create_passenger "María García"
    
    # Verificar estado del conductor
    DRIVER_ID=$(cat driver_id.txt)
    check_driver_status "$DRIVER_ID"
    
    # Crear viaje
    create_trip "Centro de la ciudad" "Aeropuerto"
    
    # Verificar estado del viaje
    TRIP_ID=$(cat trip_id.txt)
    check_trip_status "$TRIP_ID"
    
    # Verificar que el conductor ya no está disponible
    print_info "Verificando disponibilidad del conductor después del viaje..."
    check_driver_status "$DRIVER_ID"
    
    # Finalizar viaje
    finalize_trip "$TRIP_ID" "$DRIVER_ID"
    
    # Verificar estado final
    print_info "Verificando estado final del conductor..."
    check_driver_status "$DRIVER_ID"
    
    print_success "=== Demo completada exitosamente ==="
    print_info "El conductor ahora está disponible para nuevos viajes"
    
    # Preguntar si limpiar archivos
    read -p "¿Deseas limpiar los archivos temporales? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cleanup
    else
        print_info "Archivos temporales conservados para inspección"
    fi
}

# Ejecutar función principal
main "$@"
