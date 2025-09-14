#!/bin/bash

# Script principal para Go Together
# Uso: ./scripts/go_together.sh [comando] [argumentos...]

set -e

# Obtener el directorio del script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
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

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Función de ayuda
show_help() {
    echo "Uso: $0 [comando] [argumentos...]"
    echo ""
    echo "Comandos disponibles:"
    echo ""
    echo "  DESARROLLO:"
    echo "    build                    - Compilar el proyecto"
    echo "    publish                  - Publicar el módulo"
    echo "    test                     - Ejecutar tests unitarios"
    echo ""
    echo "    EJEMPLOS:"
    echo "    example-simple           - Ejecutar ejemplo simple"
    echo "    example-full             - Ejecutar ejemplo completo"
    echo ""
    echo "    PRUEBAS:"
    echo "    test-conductor           - Probar función crear_conductor"
    echo "    test-publish             - Probar extracción de package ID"
    echo "    test-registry            - Probar funciones de registro"
    echo "    test-trip                - Probar función crear_viaje"
    echo ""
    echo "    OPERACIONES:"
    echo "    create-driver <nombre> <coche> <registry_id> - Crear conductor"
    echo "    create-passenger <nombre> <registry_id> - Crear pasajero"
    echo "    create-trip <origen> <destino> <driver_id> <passenger_id> - Crear viaje"
    echo "    check-driver <driver_id> - Verificar estado del conductor"
    echo "    check-trip <trip_id> - Verificar estado del viaje"
    echo "    finalize-trip <trip_id> <driver_id> - Finalizar viaje"
    echo ""
    echo "    UTILIDADES:"
    echo "    clean                    - Limpiar archivos temporales"
    echo "    help                     - Mostrar esta ayuda"
    echo ""
    echo "Ejemplos:"
    echo "  $0 build"
    echo "  $0 example-simple"
    echo "  $0 test-conductor"
    echo "  $0 create-driver 'Juan' 'Toyota' 0x123..."
}

# Cambiar al directorio del proyecto
cd "$PROJECT_ROOT"

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

# Ejecutar tests unitarios
run_tests() {
    print_info "Ejecutando tests unitarios..."
    sui move test
    print_success "Tests completados"
}

# Ejecutar ejemplo simple
run_example_simple() {
    print_info "Ejecutando ejemplo simple..."
    "$SCRIPT_DIR/examples/ejemplo_simple.sh" "$@"
}

# Ejecutar ejemplo completo
run_example_full() {
    print_info "Ejecutando ejemplo completo..."
    "$SCRIPT_DIR/examples/ejemplo_uso.sh" "$@"
}

# Ejecutar pruebas específicas
run_test_conductor() {
    print_info "Ejecutando prueba de conductor..."
    "$SCRIPT_DIR/tests/test_conductor.sh"
}

run_test_publish() {
    print_info "Ejecutando prueba de publicación..."
    "$SCRIPT_DIR/tests/test_publish.sh"
}

run_test_registry() {
    print_info "Ejecutando prueba de registros..."
    "$SCRIPT_DIR/tests/test_registry.sh"
}

run_test_trip() {
    print_info "Ejecutando prueba de viaje..."
    "$SCRIPT_DIR/tests/test_trip.sh"
}

# Operaciones del módulo (usando ejemplo_simple.sh)
create_driver() {
    "$SCRIPT_DIR/examples/ejemplo_simple.sh" create-driver "$@"
}

create_passenger() {
    "$SCRIPT_DIR/examples/ejemplo_simple.sh" create-passenger "$@"
}

create_trip() {
    "$SCRIPT_DIR/examples/ejemplo_simple.sh" create-trip "$@"
}

check_driver() {
    "$SCRIPT_DIR/examples/ejemplo_simple.sh" check-driver "$@"
}

check_trip() {
    "$SCRIPT_DIR/examples/ejemplo_simple.sh" check-trip "$@"
}

finalize_trip() {
    "$SCRIPT_DIR/examples/ejemplo_simple.sh" finalize-trip "$@"
}

# Limpiar archivos temporales
cleanup() {
    print_info "Limpiando archivos temporales..."
    rm -f *.json *.txt
    print_success "Limpieza completada"
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
        "test")
            run_tests
            ;;
        "example-simple")
            shift
            run_example_simple "$@"
            ;;
        "example-full")
            shift
            run_example_full "$@"
            ;;
        "test-conductor")
            run_test_conductor
            ;;
        "test-publish")
            run_test_publish
            ;;
        "test-registry")
            run_test_registry
            ;;
        "test-trip")
            run_test_trip
            ;;
        "create-driver")
            shift
            create_driver "$@"
            ;;
        "create-passenger")
            shift
            create_passenger "$@"
            ;;
        "create-trip")
            shift
            create_trip "$@"
            ;;
        "check-driver")
            shift
            check_driver "$@"
            ;;
        "check-trip")
            shift
            check_trip "$@"
            ;;
        "finalize-trip")
            shift
            finalize_trip "$@"
            ;;
        "clean")
            cleanup
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
