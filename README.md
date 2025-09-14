# Go Together 🚗

A decentralized carpooling application built on the Sui blockchain using the Move programming language. This project enables users to register as drivers or passengers and create ride-sharing arrangements in a trustless, blockchain-based environment.

## 🌟 Features

- **Driver Registration**: Users can register as drivers with their vehicle information
- **Passenger Registration**: Users can register as passengers to request rides
- **Ride Booking**: Passengers can book rides with available drivers
- **Ride Management**: Track active rides and manage driver availability
- **Decentralized**: Built on Sui blockchain for transparency and security
- **Smart Contracts**: Automated ride management through Move smart contracts

## 🏗️ Architecture

### Core Components

#### Data Structures
- **`Conductor`**: Represents a driver with vehicle information and availability status
- **`Pasajero`**: Represents a passenger with wallet information
- **`Viaje`**: Represents a booked ride with origin, destination, and status
- **`RegistroConductores`**: Global registry of all registered drivers
- **`RegistroPasajeros`**: Global registry of all registered passengers

#### Key Functions
- **Driver Management**: Register drivers, check availability, update status
- **Passenger Management**: Register passengers, validate registration
- **Ride Operations**: Book rides, finalize trips, track active rides
- **Registry Management**: Maintain global registries of users

## 🚀 Getting Started

### Prerequisites

- [Sui CLI](https://docs.sui.io/build/install) installed
- Basic understanding of Move programming language
- Sui testnet or devnet access

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd go_together
```

2. Install dependencies:
```bash
sui move build
```

### Running Tests

Execute the test suite to verify functionality:

```bash
sui move test
```

The test suite includes:
- Driver registration tests
- Passenger registration tests
- Ride booking functionality tests

## 📖 Usage

### Driver Registration

1. Create a driver profile:
```move
let conductor = crear_conductor(nombre, coche, ctx);
```

2. Register the driver in the global registry:
```move
registrar_conductor(&mut registro, &mut conductor);
```

### Passenger Registration

1. Register as a passenger:
```move
registrar_pasajero(&mut registro, nombre, ctx);
```

### Booking a Ride

1. Reserve a ride with an available driver:
```move
reservar_viaje(&mut conductor, &pasajero, origen, destino, ctx);
```

2. Finalize the ride when completed:
```move
finalizar_viaje(&mut viaje, &mut conductor);
```

## 🔧 API Reference

### Driver Functions
- `crear_conductor(nombre: String, coche: String, ctx: &mut TxContext): Conductor`
- `registrar_conductor(registro: &mut RegistroConductores, conductor: &mut Conductor)`
- `esta_conductor_registrado(registro: &RegistroConductores, user: address): bool`
- `esta_disponible(conductor: &Conductor): bool`
- `actualizar_disponibilidad_conductor(conductor: &mut Conductor, disponible: bool)`

### Passenger Functions
- `registrar_pasajero(registro: &mut RegistroPasajeros, nombre: String, ctx: &mut TxContext)`
- `esta_pasajero_registrado(registro: &RegistroPasajeros, user: address): bool`

### Ride Functions
- `reservar_viaje(conductor: &mut Conductor, pasajero: &Pasajero, origen: String, destino: String, ctx: &mut TxContext)`
- `finalizar_viaje(viaje: &mut Viaje, conductor: &mut Conductor)`
- `crear_viaje(conductor: &mut Conductor, pasajero: &Pasajero, origen: String, destino: String, ctx: &mut TxContext): Viaje`
- `esta_activo(viaje: &Viaje): bool`

### Registry Functions
- `crear_registro(ctx: &mut TxContext): RegistroConductores`
- `crear_registro_pasajeros(ctx: &mut TxContext): RegistroPasajeros`
- `eliminar_registro(registro: RegistroConductores)`
- `eliminar_registro_pasajeros(registro: RegistroPasajeros)`

## 🧪 Testing

The project includes comprehensive tests covering:
- Driver registration and validation
- Passenger registration and validation
- Ride booking workflow
- Registry management

Run tests with:
```bash
sui move test
```

## 🚀 Scripts and Examples

The project includes organized bash scripts that demonstrate how to use the Sui CLI to interact with the module:

### Main Script (`go_together` or `scripts/go_together.sh`)
A unified script that provides access to all functionality:

```bash
# Using the symlink (recommended)
./go_together [comando] [argumentos...]

# Or using the full path
./scripts/go_together.sh [comando] [argumentos...]
```

Available commands:
```bash
# Development
./go_together build                    # Compilar el proyecto
./go_together publish                  # Publicar el módulo
./go_together test                     # Ejecutar tests unitarios

# Examples
./go_together example-simple           # Ejecutar ejemplo simple
./go_together example-full             # Ejecutar ejemplo completo

# Testing
./go_together test-conductor           # Probar función crear_conductor
./go_together test-publish             # Probar extracción de package ID
./go_together test-registry            # Probar funciones de registro
./go_together test-trip                # Probar función crear_viaje

# Operations
./go_together create-driver "John" "Toyota" <registry_id>
./go_together create-passenger "Mary" <registry_id>
./go_together create-trip "Downtown" "Airport" <driver_id> <passenger_id>
./go_together check-driver <driver_id>
./go_together check-trip <trip_id>
./go_together finalize-trip <trip_id> <driver_id>

# Utilities
./go_together clean                    # Limpiar archivos temporales
./go_together help                     # Mostrar ayuda
```

### Individual Scripts

#### Complete Example (`scripts/examples/ejemplo_uso.sh`)
A complete script that executes the entire carpooling flow:

```bash
./scripts/examples/ejemplo_uso.sh
```

#### Modular Script (`scripts/examples/ejemplo_simple.sh`)
A modular script for specific use cases:

```bash
# Build project
./scripts/examples/ejemplo_simple.sh build

# Publish module
./scripts/examples/ejemplo_simple.sh publish

# Create driver
./scripts/examples/ejemplo_simple.sh create-driver "John" "Toyota" <registry_id>

# Create passenger
./scripts/examples/ejemplo_simple.sh create-passenger "Mary" <registry_id>

# Create trip
./scripts/examples/ejemplo_simple.sh create-trip "Downtown" "Airport" <driver_id> <passenger_id>

# Check status
./scripts/examples/ejemplo_simple.sh check-driver <driver_id>
./scripts/examples/ejemplo_simple.sh check-trip <trip_id>

# Finalize trip
./scripts/examples/ejemplo_simple.sh finalize-trip <trip_id> <driver_id>
```

#### Test Scripts (`scripts/tests/`)
Individual test scripts for specific functionality:
- `test_conductor.sh` - Test driver creation
- `test_publish.sh` - Test package publishing
- `test_registry.sh` - Test registry functions
- `test_trip.sh` - Test trip creation

### Script Prerequisites
- Sui CLI installed
- Connection to testnet/devnet
- SUI tokens for transactions
- `jq` installed for JSON processing

See `SCRIPT_EJEMPLO.md` for detailed documentation.

## 📁 Project Structure

```
go_together/
├── sources/
│   └── go_together.move          # Main Move module
├── tests/
│   └── go_together_tests.move    # Test suite
├── scripts/
│   ├── go_together.sh            # Main unified script
│   ├── examples/
│   │   ├── ejemplo_uso.sh        # Complete demonstration script
│   │   └── ejemplo_simple.sh     # Modular script for specific cases
│   └── tests/
│       ├── test_conductor.sh     # Test driver creation
│       ├── test_publish.sh       # Test package publishing
│       ├── test_registry.sh      # Test registry functions
│       └── test_trip.sh          # Test trip creation
├── Move.toml                     # Project configuration
├── Move.lock                     # Dependency lock file
├── go_together                   # Symlink to main script (for easy access)
├── SCRIPT_EJEMPLO.md            # Script documentation
└── README.md                     # This file
```

## 🔒 Security Features

- **Access Control**: Only registered users can participate in rides
- **Availability Management**: Prevents double-booking of drivers
- **Ownership Verification**: Ensures only vehicle owners can register as drivers
- **State Validation**: Comprehensive checks before state changes

## 🌐 Blockchain Integration

This application is built for the Sui blockchain, leveraging:
- **Object Model**: Using Sui's object-centric architecture
- **Transfer System**: Secure object transfers between users
- **Transaction Context**: Proper transaction handling and validation
- **Global State**: Decentralized storage of user registries

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

For questions or support, please open an issue in the repository or contact the development team.

---

**Note**: This is a demonstration project for educational purposes. For production use, additional security audits and feature implementations would be required.
