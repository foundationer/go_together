#!/bin/bash

# Script simple para casos de uso específicos de Go Together
# Uso: ./ejemplo_simple.sh [comando] [argumentos...]

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

# Función de ayuda
show_help() {
    echo "Uso: $0 [comando] [argumentos...]"
    echo ""
    echo "Comandos disponibles:"
    echo "  build                    - Compilar el proyecto"
    echo "  publish                  - Publicar el módulo"
    echo "  create-driver <nombre> <coche> <registry_id> - Crear conductor"
    echo "  create-passenger <nombre> <registry_id> - Crear pasajero"
    echo "  create-trip <origen> <destino> <driver_id> <passenger_id> - Crear viaje"
    echo "  check-driver <driver_id> - Verificar estado del conductor"
    echo "  check-trip <trip_id> - Verificar estado del viaje"
    echo "  finalize-trip <trip_id> <driver_id> - Finalizar viaje"
    echo "  help                     - Mostrar esta ayuda"
    echo ""
    echo "Ejemplos:"
    echo "  $0 build"
    echo "  $0 create-driver 'Juan' 'Toyota' 0x123..."
    echo "  $0 create-passenger 'María' 0x456..."
}

# Compilar proyecto
build_project() {
    print_info "Compilando proyecto..."
    sui move build
    print_success "Proyecto compilado"
}

# Publicar módulo
publish_module() {
    print_info "Publicando módulo..."
    sui client publish --gas-budget 100000000
    print_success "Módulo publicado"
}

# Crear conductor
create_driver() {
    local name="$1"
    local car="$2"
    local registry_id="$3"
    
    if [ -z "$name" ] || [ -z "$car" ] || [ -z "$registry_id" ]; then
        print_error "Uso: create-driver <nombre> <coche> <registry_id>"
        exit 1
    fi
    
    print_info "Creando conductor: $name con coche: $car"
    
    # Obtener package ID del último publish
    PACKAGE_ID=$(sui client objects --json | jq -r '.[] | select(.data.type | contains("Package")) | .data.objectId' | head -1)
    
    if [ -z "$PACKAGE_ID" ]; then
        print_error "No se encontró package ID. Ejecuta 'publish' primero."
        exit 1
    fi
    
    # Crear conductor
    sui client call \
        --package "$PACKAGE_ID" \
        --module app \
        --function crear_conductor \
        --args "$name" "$car" \
        --gas-budget 10000000
    
    print_success "Conductor creado"
}

# Crear pasajero
create_passenger() {
    local name="$1"
    local registry_id="$2"
    
    if [ -z "$name" ] || [ -z "$registry_id" ]; then
        print_error "Uso: create-passenger <nombre> <registry_id>"
        exit 1
    fi
    
    print_info "Creando pasajero: $name"
    
    # Obtener package ID
    PACKAGE_ID=$(sui client objects --json | jq -r '.[] | select(.data.type | contains("Package")) | .data.objectId' | head -1)
    
    if [ -z "$PACKAGE_ID" ]; then
        print_error "No se encontró package ID. Ejecuta 'publish' primero."
        exit 1
    fi
    
    # Crear pasajero
    sui client call \
        --package "$PACKAGE_ID" \
        --module app \
        --function registrar_pasajero \
        --args "$registry_id" "$name" \
        --gas-budget 10000000
    
    print_success "Pasajero creado"
}

# Crear viaje
create_trip() {
    local origin="$1"
    local destination="$2"
    local driver_id="$3"
    local passenger_id="$4"
    
    if [ -z "$origin" ] || [ -z "$destination" ] || [ -z "$driver_id" ] || [ -z "$passenger_id" ]; then
        print_error "Uso: create-trip <origen> <destino> <driver_id> <passenger_id>"
        exit 1
    fi
    
    print_info "Creando viaje de $origin a $destination"
    
    # Obtener package ID
    PACKAGE_ID=$(sui client objects --json | jq -r '.[] | select(.data.type | contains("Package")) | .data.objectId' | head -1)
    
    if [ -z "$PACKAGE_ID" ]; then
        print_error "No se encontró package ID. Ejecuta 'publish' primero."
        exit 1
    fi
    
    # Crear viaje
    sui client call \
        --package "$PACKAGE_ID" \
        --module app \
        --function crear_viaje \
        --args "$driver_id" "$passenger_id" "$origin" "$destination" \
        --gas-budget 10000000
    
    print_success "Viaje creado"
}

# Verificar conductor
check_driver() {
    local driver_id="$1"
    
    if [ -z "$driver_id" ]; then
        print_error "Uso: check-driver <driver_id>"
        exit 1
    fi
    
    print_info "Verificando conductor: $driver_id"
    sui client object "$driver_id"
}

# Verificar viaje
check_trip() {
    local trip_id="$1"
    
    if [ -z "$trip_id" ]; then
        print_error "Uso: check-trip <trip_id>"
        exit 1
    fi
    
    print_info "Verificando viaje: $trip_id"
    sui client object "$trip_id"
}

# Finalizar viaje
finalize_trip() {
    local trip_id="$1"
    local driver_id="$2"
    
    if [ -z "$trip_id" ] || [ -z "$driver_id" ]; then
        print_error "Uso: finalize-trip <trip_id> <driver_id>"
        exit 1
    fi
    
    print_info "Finalizando viaje: $trip_id"
    
    # Obtener package ID
    PACKAGE_ID=$(sui client objects --json | jq -r '.[] | select(.data.type | contains("Package")) | .data.objectId' | head -1)
    
    if [ -z "$PACKAGE_ID" ]; then
        print_error "No se encontró package ID. Ejecuta 'publish' primero."
        exit 1
    fi
    
    # Finalizar viaje
    sui client call \
        --package "$PACKAGE_ID" \
        --module app \
        --function finalizar_viaje \
        --args "$trip_id" "$driver_id" \
        --gas-budget 10000000
    
    print_success "Viaje finalizado"
}

# Función principal
main() {
    case "$1" in
        "build")
            build_project
            ;;
        "publish")
            publish_module
            ;;
        "create-driver")
            create_driver "$2" "$3" "$4"
            ;;
        "create-passenger")
            create_passenger "$2" "$3"
            ;;
        "create-trip")
            create_trip "$2" "$3" "$4" "$5"
            ;;
        "check-driver")
            check_driver "$2"
            ;;
        "check-trip")
            check_trip "$2"
            ;;
        "finalize-trip")
            finalize_trip "$2" "$3"
            ;;
        "help"|"--help"|"-h"|"")
            show_help
            ;;
        *)
            print_error "Comando desconocido: $1"
            show_help
            exit 1
            ;;
    esac
}

# Ejecutar función principal
main "$@"
